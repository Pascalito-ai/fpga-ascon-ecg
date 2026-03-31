// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Wed Mar 11 15:29:11 2026
// Host        : HPV15 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/azert/Documents/lab_fpga_diallo/ascon_version_registre/ascon_version_registre.gen/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_12,Vivado 2025.2" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    enb,
    web,
    addrb,
    dinb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [4:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_mode = "slave BRAM_PORTB" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [0:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [4:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [63:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [4:0]addra;
  wire [4:0]addrb;
  wire clka;
  wire clkb;
  wire [63:0]dina;
  wire [63:0]dinb;
  wire [63:0]douta;
  wire [63:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire [0:0]web;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [4:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [4:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "5" *) 
  (* C_ADDRB_WIDTH = "5" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     11.8086 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "25" *) 
  (* C_READ_DEPTH_B = "25" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "64" *) 
  (* C_READ_WIDTH_B = "64" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "25" *) 
  (* C_WRITE_DEPTH_B = "25" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_mem_gen_0_blk_mem_gen_v8_4_12 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[4:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[4:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
YqH9kwIC39+qbZg4PSfFsXuB9k9wnuxNryS/CfnEri6Ci9fSC6fsrQ/T/hnt3u/yolbJ8DJa1Qu6
Qnm24A9jLbA+fu3Nsmm6/rM6a4vU6OfVl/gTFd/CiWDutv6Dhn6Lim4uUNPahoOR/A2Yc4Zo2tdI
kMLO9gn9WlH2l3O2oXs=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XJYO2VHd/cnMxQd3i7/2qRhl57dl+doEKuhAunQyv3vpGRG/jlNxj8PqrgLoF0HMdqE3qJUVE/oq
kBSapqjVjLDMOrNGQ+Tc6VGsKMZH8FE/TXHQJ/IM5Iuiu2eozEwwVUomF+7cfqn+9OsVsqCONQ1M
g0oRlangiqasJDhhMfnlGGqwAwmgWRGQA6dmhTuua1s8zdvIv540zY6p5au8cAKVhqyyKK7wbxEE
SGuFqX+NYoyRV+rfWCcWM+hJEmnWS8LNAKkd13YE2+17sPYzUdZ23DmTxXK6KlAxKFW27CBySUfg
qdNXp2DSs2KAQYih27pBNMuHfGbM/ATFPWFvxg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
lYoEi/e8HsDTz6N11EDe/B/iitERmeYndlCklmCluwgb0N4W80JUGVlkd7NlRZHRNhxaNBJPkcjC
n61nO0tb17NwsMwjbY5TF8JWRYTNw1JXCFacvQYrdKv4/7QNQEtwVGiCLxFhOA8aHlWMZIrc2fri
VRMVWaEBcPwCGorlVIM=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QEw9fEsWFbdX0OQLvYs/gl+zyEOW3ak9TdQVaq+0AXXOT3LIqF7wDxJ6ZBnlf9mNbdsUVH5tAz1o
H8u7ihJl1L3THEvugW+TS8hkvVbEA9rKO2vV15KAj4Lla7UdFT/xDfe79RFarlLI7yGrubjgdoRi
QWy//UKsffG7IWNwmoSuppWiWB4ZHJtkunNyIkm70JPGyZF62VxJg1MTT+5LUbZG5vZjjuHZud9w
xJaKv1tFP/x8RVqLU5gPOqGqTW7/nKO2S+450Vo4D9vAmBVVcXpaL1EbSmCvQ+qJmcQKtf9qYFRV
Zko08hbpHjPxstqvTDro01jRzB8592m4xU2TWA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TC7q853CWBPPJgbRfgDV1lmjUwSAtliljShAyNFg8sfRfwDzchthzoSPH1UCHV++E2JXacEKq1lB
UWsNP92U4Xh0/Gu+6esOI0pJb8I+TRTxyBN1I4cRQEfQHcwfhbSdeH3yX9OV3opLEqYmT37hWU+J
zCawYnxVESI0FtRzEXve9gdEWlrKKckrT/hp4mvxxOjvOkOSQBvy0elgUOqh6mEOZl+JnUbsR+Wm
CoZLE1eefMZy3FnVmyDNPv3JPXi88aLXMyimal0MYFkTiS4XJiGT3eAIMIbksehXY+eYi/KFpZWQ
GHpX+lG3UmiWWLwyPakFwKEHbrBc70AlJ2eV9g==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
j9nmCKgjPWNChPbpSW6EWLrMA6oCG2JGPoum8px09v0PEAh0DRXZi0J8HPzXUsZgOEMcKpA7X54u
YFcDDCLAQ+urha/eSPbQYHQh4yGCursxAQ1C6LEyNQ2wJ0eLlO2bJeAl/gof06zqsYVM2lLJVNv5
wao1k2bmgPdfpfY3c9vPD0fSMuZPS41EoRS0cQhO5GTZnKdjxm6tEUL3GnTjB8ynSCIbCJUsMtAX
4FRHNa52gudx5B5fagR+lXgFhE7e++rWTJELr7SYB+r5Es8qZLTpCH8TrQxEkV0rY/+e4sAjNE2D
gHw8GD7VcUtc15B8y1BbVmh29qc8Nd3V2i/miA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UkCD6I/Vye4qNoNoa3hIexBXG3xyKUJPAHAjIo7UcNVCDXpMQiYEtPDqExZMfiPlJn2nswCYIfIJ
FYWqMCloKSQyyI/7yZ2EtbyWEklb/P5IyZyvGi6hhFUo/JFTb12b4bK0gZPr+bCDdlVQKTx5GVHz
wptdUJO2omSj8axVMPbLRRtVzlJIZ29dTJ2ATXVXAcBxPnFfHRAMnYYKLeeLExX61vQvpqrkLQHm
XG7hpVzJi56gYKAzxa2BLq072OCVpVS70bfWlhlSTVcSlCrUf+EcarEk4FD8+Ih2NCvrqremG6yn
TtcBn8Xr8M/6zhOYvLi6AD6eArDMKA8n+Ccv8A==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
A5y5QVZU8yjPexRVPioSiAGohCHD5DX5FVobuMyhcgQRExLUhPvnnS8HOtxTj/2IapEcz68gFMGG
Hpi+m725u85/om/Vze9pGIW9Mn328Kz2FIg3W5EvGstfGwY+48LiAGAmTR269JS4lJGVYWYOz7Xk
S8cEsFd2m7j8iyKtARJzD90+UdXq/cIIh725jC9i8nbgxB364zddvm1Z/DF3JRw1qFp6GGcuRai1
KNcJ1j8c9wtIgktpsteU3e5+bxHEw8NT3gWXUFYjm00NDq97Jals8Jjktmum2nQxoF7ivPacfEey
gnSF6jRMkTsZObzc30hAhs0CEtc33hZLhPLHSn8pQ0WyvKJLHdd5s2yckgTZtqxC1Sbwe7WEgNXe
ZMX3pIkz+aoXsAL7GBLyVBMVQcyMoF0w8QGAaTe8sqatABwPqXidYRqNROTf62IYcMpV89XYgaTv
EwIn/oni9KOFd2BFVxRZbFGGC4IjvigsTBUijI+Dk6kVnDh240clGcc4

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Omtp+lCaqUx7Z4qdFj2zrN8LpCkit2eX4hlMtig+ielGm/x4FSZkpjoFmiqdKFPi2eg0pg09MSai
XyGH68UzAR7Xrj8f1jlIoUmMKp4GcxfdqfTeuu7kWGOJEP6cvgTjSJFj2gawDv7f4yZcltnK2x0L
e4GW/rBTmGvZtKWb2ahjINLxPuh3dDaSaWdb+zVgbtyrI5FrjxBkq+aOxSjyNsqnCx1L0uWbxnkl
88NbXN3dTaECXHNm/fsleayM5hKis7kTv9BFajJMGy+BhQlmIYpE+F5zchnTTFUFJZCz1sX9Fc8e
HcY7irB8mR3ajdzjUZLBQEMktp096Nheq3U75A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
hpeBLwN9x2ZFDwroYLlUe5GjjDepHik2l0c2s3/6S7JPCRkzQSyt2V1Ad/JewAs/QNp5SXSbYYB4
rQl0My1LDMF3xw43r0g2IbcyHVpPhGp0W5msuQdF67afnsRv90iJYWLMI3QkYGCTWAzl4HrLxFSg
3z8XZRK670IcxznOrlvgHmIKsvubZrBkuc1EynrVb9Nw16QnIx2rc4WgcEXeFf+4i1RoYLDd3gXK
NFCNMdtaRYUThunFP6Z4ViZ5UnDmKq+IMhd31jTaqIlWOBDxPI1+v5RJYxIyTbn4rxlKR2fNbl5/
z4OUjBTd+1GH3I2OXlqmAOvIhpe2Z2HH7nZu/A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Mt2RhTSUwEIEWeNARbyL+EdfS1UF6nPaL/fKl/7oO2gina93egwCWDLl1fbBtkfaPco0cu4MJ9K3
OraAsyHRlY+MNShmJ1LzAIA1LjZx4y55lu9dlQqSUXR7AW7wVbkg1864mK+hM/1XygU0jvebKNW9
B7xSER+asLO6pxi0mt7uC2PHxLPAYEszFhmnap82TtbDGdQ2qtyekY+ngs+N2fAdsblxVwJruiMl
e6XJ127M8N1mYwhWU2HtRpBOSnnKoHgD9fG51XK/rhk8DxT66QnX9uLPB+H25eDupBJGi1Y5o6x8
hOwZiSUVlBLh7brfzevh7+eRn+7es6wBas0+3w==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 48864)
`pragma protect data_block
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
V0d40pDu+IbQ6+7+73fY
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
