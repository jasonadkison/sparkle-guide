SparkleFormation.new(:computes) do

  parameters do
    ssh_key_name.type 'String'
    network_vpc_id.type 'String'
    network_subnet_id.type 'String'
    image_id_name do
      type 'String'
      default 'ami-63ac5803'
    end
  end

  dynamic!(:ec2_security_group, :compute) do
    properties do
      group_description 'SSH Access'
      security_group_ingress do
        cidr_ip '0.0.0.0/0'
        from_port 22
        to_port 22
        ip_protocol 'tcp'
      end
      vpc_id ref!(:network_vpc_id)
    end
  end

  dynamic!(:ec2_instance, :micro) do
    properties do
      image_id ref!(:image_id_name)
      instance_type 't2.micro'
      key_name ref!(:ssh_key_name)
      network_interfaces array!(
        ->{
          device_index 0
          associate_public_ip_address 'true'
          subnet_id ref!(:network_subnet_id)
          group_set [ref!(:compute_ec2_security_group)]
        }
      )
    end
  end

  dynamic!(:ec2_instance, :small) do
    properties do
      image_id ref!(:image_id_name)
      instance_type 't2.small'
      key_name ref!(:ssh_key_name)
      network_interfaces array!(
        ->{
          device_index 0
          associate_public_ip_address 'true'
          subnet_id ref!(:network_subnet_id)
          group_set [ref!(:compute_ec2_security_group)]
        }
      )
    end
  end

  outputs do
    micro_address.value attr!(:micro_ec2_instance, :public_ip)
    small_address.value attr!(:small_ec2_instance, :public_ip)
  end

end
