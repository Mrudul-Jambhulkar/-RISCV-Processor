module gpio_interrupt (
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] gpio_input_i,
    input wire [31:0] gpio_int_mask_i,
    input wire [31:0] gpio_int_level_i,  // Interrupt Level Configuration
    input wire [31:0] gpio_int_set_i,
    input wire [31:0] gpio_int_clr_i,
    input wire [31:0] gpio_int_mode_i,   // Interrupt Mode: 1 = Edge, 0 = Level
    output reg [31:0] gpio_int_status_o,
    output reg intr_o
);
    // Previous state storage for edge detection
    reg [31:0] gpio_input_prev_q;
    reg [31:0] edge_detect;
    reg [31:0] level_detect;
    reg [31:0] interrupt_detect;

    // Edge and Level Detection Logic
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            gpio_int_status_o <= 32'b0;
            gpio_input_prev_q <= 32'b0;
            edge_detect <= 32'b0;
            level_detect <= 32'b0;
            interrupt_detect <= 32'b0;
            intr_o <= 1'b0;
        end else begin
            // Edge detection: XOR to detect state change, masked by interrupt enable
            edge_detect <= (gpio_input_i ^ gpio_input_prev_q) & gpio_int_mask_i;
            
            // Level detection: Active-High or Active-Low based on gpio_int_level_i
            level_detect <= gpio_int_mask_i & 
                           ((gpio_input_i & gpio_int_level_i) | (~gpio_input_i & ~gpio_int_level_i));
            
            // Combine detection based on GPIO_INT_MODE (1 = Edge, 0 = Level)
            interrupt_detect <= (edge_detect & gpio_int_mode_i) | 
                                (level_detect & ~gpio_int_mode_i);
            
            // Combined interrupt status with set/clear 
            gpio_int_status_o <= (gpio_int_status_o | interrupt_detect | gpio_int_set_i) & ~gpio_int_clr_i;
            
            // Global interrupt
            intr_o <= |gpio_int_status_o;
            
            // Store previous input state 
            gpio_input_prev_q <= gpio_input_i;
        end
    end
endmodule
