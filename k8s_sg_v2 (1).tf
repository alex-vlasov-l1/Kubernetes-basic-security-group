resource "yandex_vpc_security_group" "sg-k8s" {
  name        = "sg-k8s"
  description = "apply this on both cluster and nodes, minimal security group which allows k8s cluster to work"
  network_id  = yandex_vpc_network.foo.id



  ingress {
    protocol       = "TCP"
    description    = "allows health_checks from load-balancer health check address range, needed for HA cluster to work as well as for load balancer services to work"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "allows communication within security group, needed for master-to-node, and node-to-node communication"
    predefined_target = "self_security_group"
    from_port      = 0
    to_port        = 65535
  }


    ingress {
      protocol       = "ANY"
      description    = "allows pod-pod and service-service communication, change subnets with your cluster and service CIDRs"
      v4_cidr_blocks = ["10.112.0.0/16", "10.96.0.0/16"]
      from_port      = 0
      to_port        = 65535
    }


  ingress {
    protocol       = "TCP"
    description    = "allows ssh to nodes from private addresses"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allows icmp from private subnets for troubleshooting"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  }

  egress {
    protocol       = "ANY"
    description    = "we usually allow all the egress traffic so that nodes can go outside to s3, registry, dockerhub etc."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-services"
  description = "apply this on nodes, security group that opens up inbound port ranges on nodes, so that your public-facing services can work"
  network_id  = yandex_vpc_network.foo.id

  ingress {
    protocol       = "TCP"
    description    = "allows inbound traffic from Internet on NodePort range, apply to nodes, no need to apply on master, change ports or add more rules if using custom ports"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }
}

resource "yandex_vpc_security_group" "k8s-master-whitelist" {
  name        = "k8s-master-whitelist"
  description = "apply this on cluster, to define range of ip-addresses which can access cluster API with kubectl and such"
  network_id  = yandex_vpc_network.foo.id

ingress {
  protocol       = "TCP"
  description    = "whitelist for kubernetes API, controls who can access cluster API from outside, replace with your management ip range"
  v4_cidr_blocks = ["85.32.23.22/32", "192.168.0.0/24"]
  port      = 6443

}

ingress {
  protocol       = "TCP"
  description    = "whitelist for kubernetes API, controls who can access cluster API from outside, replace with your management ip range"
  v4_cidr_blocks = ["85.32.23.22/32", "192.168.0.0/24"]
  port      = 443
}
}
