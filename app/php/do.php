<?php

///isXMLHTTPRequest() or die('Forbidden');
isset($_GET['r'])       or die('Forbidden');

$dbhost = '';
$dbname = '';
$dbuser = '';
$dbpass = '';

$mysqli = new mysqli($dbhost, $dbuser, $dbpass, $dbname);

if ($mysqli->connect_errno) {
  $error=array("error" =>  $mysqli->connect_error);
  echo json_encode($error);
  exit();
}

$mysqli->set_charset("utf8");

$method = $_GET['r'];

function isXMLHTTPRequest() {
  if ( !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest' ) {
    return true;
  } else {
    return false;
  }
}

function isValidHash($hash) {
  if ($hash != "3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy") {
    return false;
  } else {
    return true;
  }
}

switch ($method) {
case 'addRegistration':
  echo addRegistration();
  break;
case 'addPeopleWaitingR':
  echo addPeopleWaitingR();
  break;
case 'updatePersonCame':
  echo updatePersonCame();
  break;
case 'updateWaiters':
  echo updateWaiters();
  break;
case 'selectPeople':
  echo selectPeople();
  break;
default:
  $error = array("error" =>  "Undefined function.");
  echo json_encode($error);
  break;
}

$mysqli->close();

function addRegistration() {
  $data = file_get_contents("php://input");
  $objData = json_decode($data);

  if(!isset($objData->data->hash)) {
    $error = array("error" =>  "No hash value.");
    return json_encode($error);
  }
  if (!isValidHash($objData->data->hash)) {
    $error = array("error" =>  "Incorrect hash value.");
    return json_encode($error);
  }

  $mysqli = $GLOBALS['mysqli'];
  $sql = "INSERT INTO `registration` (`name`, `company`, `email`, `phone`, `department`, `where`, `updated_at`) VALUES ('".addslashes($objData->data->name)."', '".addslashes($objData->data->company)."', '".addslashes($objData->data->email)."', '".addslashes($objData->data->phone)."', '".addslashes($objData->data->department)."', '".addslashes($objData->data->where)."', NOW());";
  if ($result = $mysqli->query($sql)) {
    $id = $mysqli->insert_id;
    return $id;
  }else {
    $error = array("error" =>  "INSERT registration query error. " . $sql);
    return json_encode($error);
  }
}

function addPeopleWaitingR() {
  $data = file_get_contents("php://input");
  $objData = json_decode($data);

  if(!isset($objData->data->hash)) {
    $error = array("error" =>  "No hash value.");
    return json_encode($error);
  }
  if (!isValidHash($objData->data->hash)) {
    $error = array("error" =>  "Incorrect hash value.");
    return json_encode($error);
  }

  $mysqli = $GLOBALS['mysqli'];
  $result = false;
  $sql = '';
  foreach ($objData->data->peopleWaitingR as $waiter) {
    $sql = "INSERT INTO `registration` (`name`, `company`, `email`, `phone`, `department`, `where`, `updated_at`) VALUES ('".addslashes($waiter->name)."', '".addslashes($waiter->company)."', '".addslashes($waiter->email)."', '".addslashes($waiter->phone)."', '".addslashes($waiter->department)."', '".addslashes($waiter->finalwhere)."', NOW());";
    $result = $mysqli->query($sql);
  }
  if($result) {
    return true;
  }else {
    $error = array("error" =>  "INSERT waitersR query error.".$sql);
    return json_encode($error);
  }
}

function selectPeople() {
  $data = file_get_contents("php://input");
  $objData = json_decode($data);

  if(!isset($objData->data->hash)) {
    $error = array("error" =>  "No hash value.");
    return json_encode($error);
  }
  if (!isValidHash($objData->data->hash)) {
    $error = array("error" =>  "Incorrect hash value.");
    return json_encode($error);
  }

  $mysqli = $GLOBALS['mysqli'];
  $sql = "SELECT id, name, company, phone, came FROM `registration` ORDER BY name";
  if ($result = $mysqli->query($sql)) {
    if ($result->num_rows > 0) {
      while($row = mysqli_fetch_assoc($result)) {
        $obj[] = $row;
      }
      $result->close();
      return json_encode($obj);
    }else {
      $obj = array();
      $result->close();
      return json_encode($obj);
    }
  }else {
    $error = array("error" =>  "SELECT people query error.");
    return json_encode($error);
  }
}

function updatePersonCame() {
  $data = file_get_contents("php://input");
  $objData = json_decode($data);

  if(!isset($objData->data->hash)) {
    $error = array("error" =>  "No hash value.");
    return json_encode($error);
  }
  if (!isValidHash($objData->data->hash)) {
    $error = array("error" =>  "Incorrect hash value.");
    return json_encode($error);
  }

  $mysqli = $GLOBALS['mysqli'];
  $sql = "UPDATE `registration` SET `came` = ".$objData->data->came.", `updated_at` = NOW() WHERE id = ".$objData->data->id.";";
  if ($result = $mysqli->query($sql)) {
    return true;
  }else {
    $error = array("error" =>  "UPDATE registration query error.".$sql);
    return json_encode($error);
  }
}

function updateWaiters() {
  $data = file_get_contents("php://input");
  $objData = json_decode($data);

  if(!isset($objData->data->hash)) {
    $error = array("error" =>  "No hash value.");
    return json_encode($error);
  }
  if (!isValidHash($objData->data->hash)) {
    $error = array("error" =>  "Incorrect hash value.");
    return json_encode($error);
  }

  $mysqli = $GLOBALS['mysqli'];
  $result = false;
  $sql = '';
  foreach ($objData->data->waiters as $waiter) {
    $sql = "UPDATE `registration` SET `came` = ".$waiter->came.", `updated_at` = NOW() WHERE id = ".$waiter->id."; ";
    $result = $mysqli->query($sql);
  }
  if($result) {
    $sql = "SELECT id, name, company, phone, came FROM `registration` ORDER BY name";
    if ($result = $mysqli->query($sql)) {
      if ($result->num_rows > 0) {
        while($row = mysqli_fetch_assoc($result)) {
          $obj[] = $row;
        }
        $result->close();
        return json_encode($obj);
      }else {
        $obj = array();
        $result->close();
        return json_encode($obj);
      }
    }else {
      $error = array("error" =>  "SELECT people query error.");
      return json_encode($error);
    }

  }else {
    $error = array("error" =>  "UPDATE waiters query error.".$sql);
    return json_encode($error);
  }
}
?>