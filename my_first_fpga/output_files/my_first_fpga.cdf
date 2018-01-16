/* Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Full Version */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(5CSEMA5F31) Path("C:/fpgaProject/my_first_fpga/output_files/") File("my_first_fpga.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(SOCVHPS) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
