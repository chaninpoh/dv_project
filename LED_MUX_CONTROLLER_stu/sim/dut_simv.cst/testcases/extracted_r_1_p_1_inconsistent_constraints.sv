class c_1_1;
    rand bit[0:0] even_digit; // rand_mode = ON 
    rand int digits_0_; // rand_mode = ON 

    constraint all_digits_unique_this    // (constraint_mode = ON) (../tb/dp_alternate_seq.sv:10)
    {
       (even_digit == 1'h0);
       ((0 % (even_digit * 2)) == 1) -> (digits_0_ inside {[1:9]});
       (!((0 % (even_digit * 2)) == 1)) -> (digits_0_ == 0);
    }
endclass

program p_1_1;
    c_1_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "0xx11110zxzxx0zz0xxzz0z0x01000xxxzxzxxxxxzzzxxzzxzzzxxzzxzzxzzxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
