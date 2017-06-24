SOURCE ../default/create_mso_db-default.sql

USE `mso_requests`;
DROP USER 'mso';
CREATE USER 'mso';
GRANT ALL on mso_requests.* to 'mso' identified by 'mso123' with GRANT OPTION;
FLUSH PRIVILEGES;

USE `mso_catalog`;
DROP USER 'catalog';
CREATE USER 'catalog';
GRANT ALL on mso_catalog.* to 'catalog' identified by 'catalog123' with GRANT OPTION;
FLUSH PRIVILEGES;

LOCK TABLES `NETWORK_RESOURCE` WRITE;
/*!40000 ALTER TABLE `NETWORK_RESOURCE` DISABLE KEYS */;
/*!40000 ALTER TABLE `NETWORK_RESOURCE` ENABLE KEYS */;
insert into NETWORK_RESOURCE (id, NETWORK_TYPE, VERSION_STR, ORCHESTRATION_MODE ,DESCRIPTION, TEMPLATE_ID, NEUTRON_NETWORK_TYPE) values 
(1, "vlan",'1',"NEUTRON","Cool network",1,"BASIC");
UNLOCK TABLES;

LOCK TABLES `NETWORK_RECIPE` WRITE;
/*!40000 ALTER TABLE `NETWORK_RECIPE` DISABLE KEYS */;
INSERT INTO `NETWORK_RECIPE`(`NETWORK_TYPE`, `ACTION`, `VERSION_STR`, `DESCRIPTION`, `ORCHESTRATION_URI`, `NETWORK_PARAM_XSD`, `RECIPE_TIMEOUT`, `SERVICE_TYPE`) VALUES 
('vlan','CREATE','1',NULL,'/active-bpel/services/REST/CreateNetwork',NULL,180,NULL),
('vlan','DELETE','1',NULL,'/active-bpel/services/REST/DeleteNetwork',NULL,180,NULL);
/*!40000 ALTER TABLE `NETWORK_RECIPE` ENABLE KEYS */;
UNLOCK TABLES;

INSERT INTO `VNF_RECIPE`(`ID`, `VNF_TYPE`, `ACTION`, `VERSION_STR`, `DESCRIPTION`, `ORCHESTRATION_URI`, `VNF_PARAM_XSD`, `RECIPE_TIMEOUT`, `SERVICE_TYPE`) VALUES
(100,'VPE','CREATE','1','','/active-bpel/services/REST/CreateGenericVNF','',180,'SDN-ETHERNET-INTERNET'),
(101,'VPE','DELETE','1','','/active-bpel/services/REST/DeleteGenericVNF','',180,'SDN-ETHERNET-INTERNET');

DELETE FROM VNF_RESOURCE;
DELETE FROM HEAT_TEMPLATE_PARAMS;
DELETE FROM HEAT_TEMPLATE;
DELETE FROM HEAT_ENVIRONMENT;
