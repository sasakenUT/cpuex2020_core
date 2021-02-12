`default_nettype none

module fpu(input  wire logic [31:0] a, b,
           output logic      [31:0] c,
           input  wire logic        fpu_go,
           input  wire logic [3:0]  fpucontrol,
           input  wire logic        mode,
           output logic             fpu_valid,
           input  wire logic        clk);

  logic [31:0] faddres, fsubres, fmulres, fdivres,
               fsqrtres, ftoires, feqres, fltres, fleres, itofres;
  logic        faddrdy, fsubrdy, fmulrdy, fdivrdy,
               fsqrtrdy, ftoirdy, feqrdy, fltrdy, flerdy, itofrdy;

  // Instanciate fpu modules
  fadd  fadd(a, b, fpu_go, clk, faddres, faddrdy);
  fsub  fsub(a, b, fpu_go, clk, fsubres, fsubrdy);
  fmul  fmul(a, b, fpu_go, clk, fmulres, fmulrdy);
  fdiv  fdiv(a, b, fpu_go, clk, fdivres, fdivrdy);
  fsqrt fsqrt(a, fpu_go, clk, fsqrtres, fsqrtrdy);
  ftoi  ftoi(a, mode, fpu_go, clk, ftoires, ftoirdy);
  feq   feq(a, b, fpu_go, clk, feqres, feqrdy);
  flt   flt(a, b, fpu_go, clk, fltres, fltrdy);
  fle   fle(a, b, fpu_go, clk ,fleres, flerdy);
  itof  itof(a, fpu_go, clk, itofres, itofrdy);

  // select output
  mux10v  resmux(faddres, fsubres, fmulres, fdivres, fsqrtres, ftoires,
                 feqres, fltres, fleres, itofres, fpucontrol, c);
  mux10s  rdymux(faddrdy, fsburdy, fmulrdy, fdivrdy, fsqrtrdy, ftoirdy,
                 feqrdy, fltrdy, flerdy, itofrdy, fpucontrol, fpu_valid);

endmodule

`default_nettype wire
