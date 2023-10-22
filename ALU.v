//! @title ALU
//! @author Fausto Lavezzari & Franco Viotti
//! @date 11-09-2023

//! -Implementacion de una Unidad
//!  Aritmetica logica
module ALU
#(
   parameter NB_AB     =   4, //! Numero de bits de operandos
   parameter NB_OP     =   6, //! Numero de bits de codigo de operacion
   parameter ADD       =   6'b100000,
   parameter SUB       =   6'b100010,
   parameter AND       =   6'b100100,
   parameter OR        =   6'b100101,
   parameter XOR       =   6'b100110,
   parameter SRA       =   6'b000011,
   parameter SRL       =   6'b000010,
   parameter NOR       =   6'b100111
 )
 (
   input           [NB_OP - 1: 0] i_opcode,        //! Codigo de operacion
   input   signed  [NB_AB - 1: 0] i_A,             //! Operando A
   input   signed  [NB_AB - 1: 0] i_B,             //! Operando B
   output  signed  [NB_AB - 1: 0] o_result         //! Resultado
 );


reg signed [NB_AB - 1 : 0]    tmp_reg;

always @(*)
begin
  case (i_opcode)
    ADD   :
      tmp_reg = i_A + i_B;
    SUB   :
      tmp_reg = i_A - i_B;
    AND   :
      tmp_reg = i_A & i_B;
    OR    :
      tmp_reg = i_A | i_B;
    XOR   :
      tmp_reg = i_A ^ i_B;
    NOR   :
      tmp_reg = ~(i_A ^ i_B);
    SRA   :
      tmp_reg = i_A >>> i_B;
    SRL   :
      tmp_reg = i_A >> i_B;
    default:
      tmp_reg = {NB_AB{1'bz}};
  endcase
end

assign o_result = tmp_reg;

endmodule