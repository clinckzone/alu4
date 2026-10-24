`timescale 1ns/1ps

module alu4_tb;
	reg [3:0] a;
	reg [3:0] b;
	reg [1:0] op;
	reg [4:0] expected;

	wire [3:0] y;
  wire carry_out;
	
	integer i;
	integer j;
	integer k;
	integer test_count;

	alu4 dut (
		.a(a),
		.b(b),
		.op(op),
		.y(y),
		.carry_out(carry_out)
	);

	task check_expected;
		input [3:0] expected_value;
		input expected_carry;
		
		begin
			if (y !== expected_value) begin
				$display("Total tests successfully executed: %d", test_count);
				$fatal(1, "a=%b, b=%b,op=%b: %b doesn't match expected value %b!", a, b, op, y, expected_value);
			end

			if (carry_out !== expected_carry) begin
				$display("Total tests successfully executed: %d", test_count);
				$fatal(1, "a=%b, b=%b, op=%b: %b doesn't match expected carry %b!", a, b, op, carry_out, expected_carry);
			end
		end
	endtask
	
	task compute_expected;
		begin
			case (op)
				2'b00: begin
					expected = a + b;
				end

				2'b01: begin
					expected = a & b;
				end

				2'b10: begin
					expected = a | b;
				end

				2'b11: begin
					expected = a ^ b;
				end
			endcase
		end
	endtask

	initial begin
		i = 0;
		j = 0;
		k = 0;
		test_count = 0;

		a = 4'b0;
		b = 4'b0;
		op = 2'b00;
		
		for (i = 0; i < 16; i = i + 1) begin
			for (j = 0; j < 16; j = j + 1) begin
				a = i;
				b = j;
				
				for (k = 0; k < 4; k = k + 1) begin
					op = k;

					compute_expected();
					#1
					check_expected(expected[3:0], expected[4]);
					test_count = test_count + 1;
				end
			end
		end
		
		$display("Total tests successfully executed: %d", test_count);
		$display("PASS! All checks successful.");
		$finish;
	end
endmodule

