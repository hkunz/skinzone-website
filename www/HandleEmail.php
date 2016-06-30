<?php
$sToEmail = har_rki219_mc2e@yahoo.com;
$sSubject = "SkinZone Response";
$sFromEmail = $_POST["sEmail"];
$sMessage = $_POST["sMessage"];
$sHeaders = "From: " . $_POST["sName"] ." ". $_POST["sName"] . "<" . $sFromEmail .">\r\n";
$sHeaders .= "Reply-To: " . $sFromEmail . "\r\n";
$sHeaders .= "Return-path: " . $sFromEmail;
mail($sToEmail, $sSubject, $sMessage, $sHeaders);
?>
