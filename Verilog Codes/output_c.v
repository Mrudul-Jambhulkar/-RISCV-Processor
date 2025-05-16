module gpio_output_logic (
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] gpio_direction_i,
    input wire [31:0] gpio_output_i,
    input wire [31:0] gpio_output_set_i,
    input wire [31:0] gpio_output_clr_i,
    output reg [31:0] gpio_output_o
    //output reg [31:0] gpio_output_enable_o
);

    // Internal signal for output value calculation
    wire [31:0] next_output;
    
    // Calculate next output value
    assign next_output = (gpio_output_i | gpio_output_set_i) & ~gpio_output_clr_i;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            gpio_output_o <= 32'b0;
            //gpio_output_enable_o <= 32'b0;
        end else begin
            gpio_output_o <= next_output;
            //gpio_output_enable_o <= gpio_direction_i;
        end
    end

endmodule