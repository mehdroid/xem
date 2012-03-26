<?
class DBObject{
	private $cache;
	private $dataFields = array();
	private $className;
	private $objs = array();

	protected $oh;
	protected $db;
	protected $table = "";

	public $id = 0;
	public $initialData = array();

	function __construct($oh, $dataFields, $id){
		log_message('debug','New '.get_class($this));
		$this->oh = $oh;
		$this->db = $oh->db;
		$this->cache = $oh->cache;
		$this->history = $oh->history;

		$this->className = strtolower(get_class($this));
		$this->table = $this->className."s";
		$this->dataFields = $dataFields;

		$this->id = $id;
		if($this->id)
			$this->load();
	}

	public function save(){
		if(!$this->id)
			$this->load();
	    $updateted = false;
	    $dbEntry = $this->db->get_where($this->table, array('id'=>$this->id));
		log_message('debug',$this->db->last_query());
		if(rows($dbEntry)){
		    $valueArray = $this->buildNameValueArray($this->dataFields);
		    log_message('debug', 'valueArray while saving '.print_r($valueArray,true));
		    $diff = array_diff_assoc($valueArray, $this->initialData); // create diff to see if something realy changed
		    log_message('debug', 'array_diff while saving '.print_r($diff,true));
            if($diff){
    			$this->history->createEvent('update',$this);
    			$this->clearNamespace();
    			log_message('debug',"updating a ".$this->className." id:".$this->id);
    			$this->db->update($this->table, $valueArray, array("id"=>$this->id));
		        log_message('debug',$this->db->last_query());
            }
            $updateted = true;
		}else{
			log_message('debug',"inserting new ".$this->className."... ");
			$this->db->insert($this->table, $this->buildNameValueArray($this->dataFields, $this->id));
		    log_message('debug',$this->db->last_query());
		    if(!$this->id)
			    $this->id = $this->db->insert_id();
			log_message('debug',"new id: ".$this->id);
			$this->history->createEvent('insert',$this);
			$this->clearNamespace();
		}
		return $this->id;
	}

	public function load(){
		if(!$this->id){
			log_message('debug',"loading a ".$this->className." without id");
			$testRes = $this->db->get_where($this->table, $this->buildNameValueArray($this->dataFields));
			//print_query($this->db);
			if(rows($testRes)){
				$thisFromDb = $testRes->row_array();
				$this->id = $thisFromDb['id'];
				unset($thisFromDb['id']);
				$this->initialData = $thisFromDb;
			}
		}else{
			if($cachedObj = $this->cache->hasCache(get_class($this),$this->id)){

				log_message('debug',"loading a ".$this->className." from cache with id: ".$this->id);
				$this->setAtributes($cachedObj->buildNameValueArray());

			}else{

				log_message('debug',"loading a ".$this->className." with id: ".$this->id);
				$testRes = $this->db->get_where($this->table, array("id"=>$this->id));
				if(rows($testRes)){
					$this->setAtributes($testRes->row_array());
					$this->cache->add($this);
				}
			}
			$this->initialData = $this->buildNameValueArray();
		}
	}

	public function buildNameValueArray($sourceArray=false, $includeID=false){
		if(!$sourceArray)
			$sourceArray = $this->dataFields;
		$result = array();
		foreach($sourceArray as $name){
			if(isset($this->$name))
				$result[$name] = $this->$name;
		}
		if ($includeID) {
		    $result['id'] = $this->id;
		}

		return $result;
	}

	private function setAtributes($array){
		foreach($array as $name=>$value){
		    if(is_numeric($value))
    			$this->$name = (int)$value;
    	    else
    			$this->$name = $value;

			if(endswith($name, "_id")){
				$name = explode("_",$name);
				$name = $name[0];
				if($name == "origin" || $name == "destination")
					$name = "location";
				$objName = ucfirst($name);
				$this->$name = new $objName($this->oh, $value);
				$this->objs[$name] =& $this->$name;
			}

		}
	}

	public function __toString(){
    	$out = $this->buildNameValueArray($this->dataFields);
    	$out['id'] = $this->id;
    	//$out = array();
    	foreach($this->objs as $name=>$obj){
    		$curString = (string)$obj;
    		$newString = "";
    		$count = 0;
    		foreach(preg_split("/(\r?\n)/", $curString) as $line){
    			if($count)
				    $newString .= "     ".$line."\n";
				$count++;
			}
    		$out[$name] = $newString;
    	}
        return str_replace("Array",$this->className."(".$this->id.")",print_r($out, true));
    }

    protected function clearNamespace() {
        //print "clear namespace for ".$this->className;
        if($this->className == 'plement')
			$this->oh->dbcache->clearNamespace($this->id);
	    elseif ($this->className == 'season' OR $this->className == 'name' OR $this->className == 'directrule' OR $this->className == 'passthru')
			$this->oh->dbcache->clearNamespace($this->element_id);
    }

    function delete(){
    	if(!$this->id){
			$this->load();
    	}
		if($this->id){
			$this->history->createEvent('delete',$this);
			$this->clearNamespace();
			$this->db->delete($this->table,array("id"=>$this->id));
			$this->id = 0;
			return true;
		}
		else
			return false;
	}
}




