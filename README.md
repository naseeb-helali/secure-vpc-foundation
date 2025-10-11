flowchart LR
  subgraph Public_Subnet
    IGW[Internet Gateway]
    Bastion[Bastion Host (EIP)]
    NATi[NAT Instance]
  end
