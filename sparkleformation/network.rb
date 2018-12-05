SparkleFormation.new(:network) do

  parameters do
    cidr_prefix do
      type 'String'
      default '172.20'
    end
  end

  dynamic!(:ec2_vpc, :network) do
    properties do
      cidr_block join!(ref!(:cidr_prefix), '.0.0/24')
      enable_dns_support true
      enable_dns_hostnames true
    end
  end

  dynamic!(:ec2_dhcp_options, :network) do
    properties do
      domain_name join!(region!, 'compute.internal')
      domain_name_servers ['AmazonProvidedDNS']
    end
  end

  dynamic!(:ec2_vpc_dhcp_options_association, :network) do
    properties do
      dhcp_options_id ref!(:network_ec2_dhcp_options)
      vpc_id ref!(:network_ec2_vpc)
    end
  end

  dynamic!(:ec2_internet_gateway, :network)

  dynamic!(:ec2_vpc_gateway_attachment, :network) do
    properties do
      internet_gateway_id ref!(:network_ec2_internet_gateway)
      vpc_id ref!(:network_ec2_vpc)
    end
  end

  dynamic!(:ec2_route_table, :network) do
    properties.vpc_id ref!(:network_ec2_vpc)
  end

  dynamic!(:ec2_route, :network_public) do
    properties do
      destination_cidr_block '0.0.0.0/0'
      gateway_id ref!(:network_ec2_internet_gateway)
      route_table_id ref!(:network_ec2_route_table)
    end
  end

  dynamic!(:ec2_subnet, :network) do
    properties do
      availability_zone select!(0, azs!)
      cidr_block join!(ref!(:cidr_prefix), '.0.0/24')
      vpc_id ref!(:network_ec2_vpc)
    end
  end

  dynamic!(:ec2_subnet_route_table_association, :network) do
    properties do
      route_table_id ref!(:network_ec2_route_table)
      subnet_id ref!(:network_ec2_subnet)
    end
  end

  outputs do
    network_vpc_id.value ref!(:network_ec2_vpc)
    network_subnet_id.value ref!(:network_ec2_subnet)
    network_route_table.value ref!(:network_ec2_route_table)
    network_cidr.value join!(ref!(:cidr_prefix), '.0.0/24')
  end

end
