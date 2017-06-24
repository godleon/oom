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

LOCK TABLES `heat_environment` WRITE;
/*!40000 ALTER TABLE `heat_environment` DISABLE KEYS */;
INSERT INTO `heat_environment` VALUES (3,'base_vlb.env','1.0','dns-service/DNSResource-1','BASE VLB ENV file','parameters:\n  vlb_image_name: Ubuntu_14.04.5_LTS\n  vlb_flavor_name: m1.medium\n  public_net_id: 5a88ca9c-7fbb-4232-8d8e-46b53e492de9\n  vlb_private_net_id: zdfw1lb01_private\n  ecomp_private_net_id: onap_oam\n  vlb_private_net_cidr: 192.168.10.0/24\n  ecomp_private_net_cidr: 192.168.9.0/24\n  vlb_private_ip_0: 192.168.10.111\n  vlb_private_ip_1: 192.168.9.111\n  vdns_private_ip_0: 192.168.10.211\n  vdns_private_ip_1: 192.168.9.211\n  vlb_name_0: zdfw1lb01lb01\n  vdns_name_0: zdfw1lb01dns01\n  vnf_id: vLoadBalancer_demo_app\n  vf_module_id: vLoadBalancer\n  webserver_ip: 162.242.237.182\n  dcae_collector_ip: 192.168.9.1\n  key_name: vlb_key\n  pub_key: INSERT YOUR PUBLIC KEY HERE','2016-11-14 13:04:07','EnvArtifact-UUID1','Label');
INSERT INTO `heat_environment` VALUES (4,'dnsscaling.env','1.0','dns-service/DNSResource-1','DNS Scaling ENV file','parameters:\n  vlb_image_name: Ubuntu_14.04.5_LTS\n  vlb_flavor_name: m1.medium\n  public_net_id: 5a88ca9c-7fbb-4232-8d8e-46b53e492de9\n  vlb_private_net_id: zdfw1lb01_private\n  ecomp_private_net_id: onap_oam\n  vlb_private_ip_0: 192.168.10.111\n  vlb_private_ip_1: 192.168.9.111\n  vdns_private_ip_0: 192.168.10.222\n  vdns_private_ip_1: 192.168.9.222\n  vdns_name_0: zdfw1lb01dns02\n  vnf_id: vLoadBalancer_demo_app\n  vf_module_id: vLoadBalancer\n  webserver_ip: 162.242.237.182\n  dcae_collector_ip: 192.168.9.1\n  key_name: vlb_key\n  pub_key: INSERT YOUR PUBLIC KEY HERE','2016-11-14 13:04:07','EnvArtifact-UUID2','Label');
/*!40000 ALTER TABLE `heat_environment` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `heat_template` WRITE;
/*!40000 ALTER TABLE `heat_template` DISABLE KEYS */;
INSERT INTO `heat_template` VALUES (6,'base_vlb.yaml','1.0','DNSResource','base_vlb.yaml','heat_template_version: 2013-05-23\n\ndescription: Heat template to deploy vLoadBalancer/vDNS demo app for OpenECOMP\n\nparameters:\n  vlb_image_name:\n    type: string\n    label: Image name or ID\n    description: Image to be used for compute instance\n  vlb_flavor_name:\n    type: string\n    label: Flavor\n    description: Type of instance (flavor) to be used\n  public_net_id:\n    type: string\n    label: Public network name or ID\n    description: Public network that enables remote connection to VNF\n  vlb_private_net_id:\n    type: string\n    label: vLoadBalancer private network name or ID\n    description: Private network that connects vLoadBalancer with vDNSs\n  ecomp_private_net_id:\n    type: string\n    label: ECOMP management network name or ID\n    description: Private network that connects ECOMP component and the VNF\n  vlb_private_net_cidr:\n    type: string\n    label: vLoadBalancer private network CIDR\n    description: The CIDR of the vLoadBalancer private network\n  ecomp_private_net_cidr:\n    type: string\n    label: ECOMP private network CIDR\n    description: The CIDR of the protected private network\n  vlb_private_ip_0:\n    type: string\n    label: vLoadBalancer private IP address towards the private network\n    description: Private IP address that is assigned to the vLoadBalancer to communicate with the vDNSs\n  vlb_private_ip_1:\n    type: string\n    label: vLoadBalancer private IP address towards the ECOMP management network\n    description: Private IP address that is assigned to the vLoadBalancer to communicate with ECOMP components\n  vdns_private_ip_0:\n    type: string\n    label: vDNS private IP address towards the private network\n    description: Private IP address that is assigned to the vDNS to communicate with the vLoadBalancer\n  vdns_private_ip_1:\n    type: string\n    label: vDNS private IP address towards the ECOMP management network\n    description: Private IP address that is assigned to the vDNS to communicate with ECOMP components\n  vlb_name_0:\n    type: string\n    label: vLoadBalancer name\n    description: Name of the vLoadBalancer\n  vdns_name_0:\n    type: string\n    label: vDNS name\n    description: Name of the vDNS\n  vnf_id:\n    type: string\n    label: VNF ID\n    description: The VNF ID is provided by ECOMP\n  vf_module_id:\n    type: string\n    label: vFirewall module ID\n    description: The vLoadBalancer Module ID is provided by ECOMP\n  webserver_ip:\n    type: string\n    label: Webserver IP address\n    description: IP address of the webserver that hosts the source code and binaries\n  dcae_collector_ip:\n    type: string\n    label: DCAE collector IP address\n    description: IP address of the DCAE collector\n  key_name:\n    type: string\n    label: Key pair name\n    description: Public/Private key pair name\n  pub_key:\n    type: string\n    label: Public key\n    description: Public key to be installed on the compute instance\n\nresources:\n  my_keypair:\n    type: OS::Nova::KeyPair\n    properties:\n      name: { get_param: key_name }\n      public_key: { get_param: pub_key }\n      save_private_key: false\n\n  vlb_private_network:\n    type: OS::Neutron::Net\n    properties:\n      name: { get_param: vlb_private_net_id }\n\n  vlb_private_subnet:\n    type: OS::Neutron::Subnet\n    properties:\n      name: { get_param: vlb_private_net_id }\n      network_id: { get_resource: vlb_private_network }\n      cidr: { get_param: vlb_private_net_cidr }\n\n  vlb_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vlb_image_name }\n      flavor: { get_param: vlb_flavor_name }\n      name: { get_param: vlb_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vlb_private_0_port }\n        - port: { get_resource: vlb_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __webserver__: { get_param: webserver_ip }\n            __dcae_collector_ip__: { get_param: dcae_collector_ip }\n            __local_private_ipaddr__: { get_param: vlb_private_ip_0 }\n          template: |\n            #!/bin/bash\n\n            WEBSERVER_IP=__webserver__\n            DCAE_COLLECTOR_IP=__dcae_collector_ip__\n            LOCAL_PRIVATE_IPADDR=__local_private_ipaddr__\n\n            mkdir /opt/config\n            cd /opt\n            wget http://$WEBSERVER_IP/demo_repo/v_lb_init.sh\n            wget http://$WEBSERVER_IP/demo_repo/vlb.sh\n            chmod +x v_lb_init.sh\n            chmod +x vlb.sh\n            echo $WEBSERVER_IP > config/webserver_ip.txt\n            echo $DCAE_COLLECTOR_IP > config/dcae_collector_ip.txt\n            echo $LOCAL_PRIVATE_IPADDR > config/local_private_ipaddr.txt\n            echo "no" > config/install.txt\n            LOCAL_PUBLIC_IPADDR=$(ifconfig eth0 | grep "inet addr" | tr -s \' \' | cut -d\' \' -f3 | cut -d\':\' -f2)\n            echo $LOCAL_PUBLIC_IPADDR > config/local_public_ipaddr.txt\n            mv vlb.sh /etc/init.d\n            update-rc.d vlb.sh defaults\n            ./v_lb_init.sh\n\n  vlb_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_resource: vlb_private_network }\n      fixed_ips: [{"subnet": { get_resource: vlb_private_subnet }, "ip_address": { get_param: vlb_private_ip_0 }}]\n\n  vlb_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: ecomp_private_net_id }\n      fixed_ips: [{"subnet": { get_param: ecomp_private_net_id }, "ip_address": { get_param: vlb_private_ip_1 }}]\n\n  vdns_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vlb_image_name }\n      flavor: { get_param: vlb_flavor_name }\n      name: { get_param: vdns_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vdns_private_0_port }\n        - port: { get_resource: vdns_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __webserver__: { get_param: webserver_ip }\n            __lb_oam_int__ : { get_param: vlb_private_ip_1 }\n            __lb_private_ipaddr__: { get_param: vlb_private_ip_0 }\n            __local_private_ipaddr__: { get_param: vdns_private_ip_0 }\n          template: |\n            #!/bin/bash\n\n            WEBSERVER_IP=__webserver__\n            LB_OAM_INT=__lb_oam_int__\n            LB_PRIVATE_IPADDR=__lb_private_ipaddr__\n            LOCAL_PRIVATE_IPADDR=__local_private_ipaddr__\n\n            mkdir /opt/config\n            cd /opt\n            wget http://$WEBSERVER_IP/demo_repo/v_dns_init.sh\n            wget http://$WEBSERVER_IP/demo_repo/vdns.sh\n            chmod +x v_dns_init.sh\n            chmod +x vdns.sh\n            echo $WEBSERVER_IP > config/webserver_ip.txt\n            echo $LB_OAM_INT > config/lb_oam_int.txt\n            echo $LB_PRIVATE_IPADDR > config/lb_private_ipaddr.txt\n            echo $LOCAL_PRIVATE_IPADDR > config/local_private_ipaddr.txt\n            echo "no" > config/install.txt\n            mv vdns.sh /etc/init.d\n            update-rc.d vdns.sh defaults\n            ./v_dns_init.sh\n\n  vdns_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_resource: vlb_private_network }\n      fixed_ips: [{"subnet": { get_resource: vlb_private_subnet }, "ip_address": { get_param: vdns_private_ip_0 }}]\n\n  vdns_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: ecomp_private_net_id }\n      fixed_ips: [{"subnet": { get_param: ecomp_private_net_id }, "ip_address": { get_param: vdns_private_ip_1 }}]\n',300,'Artifact-UUID1','Base VLB Heat','label','2016-11-14 13:04:07',NULL);
INSERT INTO `heat_template` VALUES (7,'dnsscaling.yaml','1.0','DNSResource','dnsscaling.yaml','heat_template_version: 2013-05-23\n\ndescription: Heat template to deploy a vDNS for OpenECOMP (scaling-up scenario)\n\nparameters:\n  vlb_image_name:\n    type: string\n    label: Image name or ID\n    description: Image to be used for compute instance\n  vlb_flavor_name:\n    type: string\n    label: Flavor\n    description: Type of instance (flavor) to be used\n  public_net_id:\n    type: string\n    label: Public network name or ID\n    description: Public network that enables remote connection to VNF\n  vlb_private_net_id:\n    type: string\n    label: vLoadBalancer private network name or ID\n    description: Private network that connects vLoadBalancer with vDNSs\n  ecomp_private_net_id:\n    type: string\n    label: ECOMP management network name or ID\n    description: Private network that connects ECOMP component and the VNF\n  vlb_private_ip_0:\n    type: string\n    label: vLoadBalancer private IP address towards the private network\n    description: Private IP address that is assigned to the vLoadBalancer to communicate with the vDNSs\n  vlb_private_ip_1:\n    type: string\n    label: vLoadBalancer private IP address towards the ECOMP management network\n    description: Private IP address that is assigned to the vLoadBalancer to communicate with ECOMP components\n  vdns_private_ip_0:\n    type: string\n    label: vDNS private IP address towards the private network\n    description: Private IP address that is assigned to the vDNS to communicate with the vLoadBalancer\n  vdns_private_ip_1:\n    type: string\n    label: vDNS private IP address towards the ECOMP management network\n    description: Private IP address that is assigned to the vDNS to communicate with ECOMP components\n  vdns_name_0:\n    type: string\n    label: vDNS name\n    description: Name of the vDNS\n  vnf_id:\n    type: string\n    label: VNF ID\n    description: The VNF ID is provided by ECOMP\n  vf_module_id:\n    type: string\n    label: vFirewall module ID\n    description: The vLoadBalancer Module ID is provided by ECOMP\n  webserver_ip:\n    type: string\n    label: Webserver IP address\n    description: IP address of the webserver that hosts the source code and binaries\n  dcae_collector_ip:\n    type: string\n    label: DCAE collector IP address\n    description: IP address of the DCAE collector\n  key_name:\n    type: string\n    label: Key pair name\n    description: Public/Private key pair name\n  pub_key:\n    type: string\n    label: Public key\n    description: Public key to be installed on the compute instance\n\nresources:\n  vdns_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vlb_image_name }\n      flavor: { get_param: vlb_flavor_name }\n      name: { get_param: vdns_name_0 }\n      key_name: { get_param: key_name }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vdns_private_0_port }\n        - port: { get_resource: vdns_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __webserver__: { get_param: webserver_ip }\n            __lb_oam_int__ : { get_param: vlb_private_ip_1 }\n            __lb_private_ipaddr__: { get_param: vlb_private_ip_0 }\n            __local_private_ipaddr__: { get_param: vdns_private_ip_0 }\n          template: |\n            #!/bin/bash\n\n            WEBSERVER_IP=__webserver__\n            LB_OAM_INT=__lb_oam_int__\n            LB_PRIVATE_IPADDR=__lb_private_ipaddr__\n            LOCAL_PRIVATE_IPADDR=__local_private_ipaddr__\n\n            mkdir /opt/config\n            cd /opt\n            wget http://$WEBSERVER_IP/demo_repo/v_dns_init.sh\n            wget http://$WEBSERVER_IP/demo_repo/vdns.sh\n            chmod +x v_dns_init.sh\n            chmod +x vdns.sh\n            echo $WEBSERVER_IP > config/webserver_ip.txt\n            echo $LB_OAM_INT > config/lb_oam_int.txt\n            echo $LB_PRIVATE_IPADDR > config/lb_private_ipaddr.txt\n            echo $LOCAL_PRIVATE_IPADDR > config/local_private_ipaddr.txt\n            echo "no" > config/install.txt\n            mv vdns.sh /etc/init.d\n            update-rc.d vdns.sh defaults\n            ./v_dns_init.sh\n\n  vdns_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: vlb_private_net_id }\n      fixed_ips: [{"subnet": { get_param: vlb_private_net_id }, "ip_address": { get_param: vdns_private_ip_0 }}]\n\n  vdns_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: ecomp_private_net_id }\n      fixed_ips: [{"subnet": { get_param: ecomp_private_net_id }, "ip_address": { get_param: vdns_private_ip_1 }}]\n',300,'Artifact-UUID2','DNS Scaling Heat','label','2016-11-14 13:04:07',NULL);
/*!40000 ALTER TABLE `heat_template` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `heat_template_params` WRITE;
/*!40000 ALTER TABLE `heat_template_params` DISABLE KEYS */;
INSERT INTO `heat_template_params` VALUES (110,6,'vlb_flavor_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (111,6,'vlb_private_ip_1','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (112,6,'dcae_collector_ip','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (113,6,'vlb_private_net_cidr','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (114,6,'ecomp_private_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (115,6,'vnf_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (116,6,'key_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (117,6,'pub_key','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (118,6,'vlb_private_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (119,6,'webserver_ip','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (120,6,'vdns_private_ip_1','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (121,6,'public_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (122,6,'vlb_private_ip_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (123,6,'vlb_name_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (124,6,'vdns_private_ip_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (125,6,'vdsn_name_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (126,6,'ecomp_private_net_cidr','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (127,6,'vf_module_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (128,6,'vlb_image_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (129,7,'vnf_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (130,7,'vf_module_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (131,7,'vlb_flavor_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (132,7,'vlb_image_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (133,7,'vdns_private_ip_1','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (134,7,'dcae_collector_ip','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (135,7,'webserver_ip','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (136,7,'vlb_private_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (137,7,'vdns_private_ip_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (138,7,'vdsn_name_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (139,7,'vlb_private_ip_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (140,7,'pub_key','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (141,7,'public_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (142,7,'key_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (143,7,'ecomp_private_net_id','\1','string',NULL);
/*!40000 ALTER TABLE `heat_template_params` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `service` WRITE;
/*!40000 ALTER TABLE `service` DISABLE KEYS */;
INSERT INTO `service` VALUES (10,'dns-service','1.0','dns service for unit test','1e34774e-715e-4fd6-bd09-7b654622f35i',NULL,NULL,'2016-11-14 13:04:07','585822c8-4027-4f84-ba50-e9248606f111');
/*!40000 ALTER TABLE `service` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `vf_module` WRITE;
/*!40000 ALTER TABLE `vf_module` DISABLE KEYS */;
INSERT INTO `vf_module` VALUES (7,'dns-service/DNSResource-1::VF_RI1_DNS::module-1','1.0','VF_RI1_DNS::module-1','1.0','1e34774e-715e-4fd5-bd08-7b654622f33e.VF_RI1_DNS::module-1::module-1.group',NULL,6,1,'2016-11-14 13:04:07',NULL,NULL,6,3,'585822c7-4027-4f84-ba50-e9248606f132');
INSERT INTO `vf_module` VALUES (8,'dns-service/DNSResource-1::VF_RI1_DNS::module-2','1.0','VF_RI1_DNS::module-2','1.0','1e34774e-715e-4fd5-bd08-7b654622f33e.VF_RI1_DNS::module-2::module-1.group',NULL,7,0,'2016-11-14 13:04:07',NULL,NULL,6,4,'585822c7-4027-4f84-ba50-e9248606f133');
/*!40000 ALTER TABLE `vf_module` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `vnf_resource` WRITE;
/*!40000 ALTER TABLE `vnf_resource` DISABLE KEYS */;
INSERT INTO `vnf_resource` VALUES (6,'dns-service/DNSResource-1','1.0','HEAT','dns service for unit test',NULL,NULL,'2016-11-14 13:04:07','585822c7-4027-4f84-ba50-e9248606f131',NULL,NULL,'585822c7-4027-4f84-ba50-e9248606f112','1.0','DNSResource-1','DNSResource','585822c8-4027-4f84-ba50-e9248606f111');
/*!40000 ALTER TABLE `vnf_resource` ENABLE KEYS */;
UNLOCK TABLES;