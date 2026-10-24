module alu4 (
	input wire [3:0] a,
	input wire [3:0] b,
	input wire [1:0] op,
	output reg [3:0] y,
	output reg carry_out
);
	reg [4:0] temp_sum;

	always @(*) begin
		temp_sum = 5'b0;

		case (op)
			2'b00: begin
				temp_sum = a + b;
				y = temp_sum[3:0];
				carry_out = temp_sum[4];
			end

			2'b01: begin
				y = a & b;
				carry_out = 1'b0;
			end

			2'b10: begin
				y = a | b;
				carry_out = 1'b0;
			end

			2'b11: begin
				y = a ^ b;
				carry_out = 1'b0;
			end
		endcase
	end
endmodule

