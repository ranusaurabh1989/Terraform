output "subnet_ids" {
  value = "${
    map(    
      "workers_ad1","${split(",",join(",", oci_core_subnet.workers_ad1.*.id))}",
      "workers_ad2","${split(",",join(",", oci_core_subnet.workers_ad2.*.id))}",
      "workers_ad3","${split(",",join(",", oci_core_subnet.workers_ad3.*.id))}",
      "lb_ad1","${split(",",join(",", oci_core_subnet.lb_ad1.*.id))}",
      "lb_ad2","${split(",",join(",", oci_core_subnet.lb_ad2.*.id))}",
      "lb_ad3","${split(",",join(",", oci_core_subnet.lb_ad3.*.id))}",      
     )  
  }"
}
