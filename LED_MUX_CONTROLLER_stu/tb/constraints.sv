
typedef enum {BLUE, GREEN, YELLOW, RED} team_t;
class person;
string name;
randc bit [6:0] idx;
rand team_t team_val;

        constraint c{ /*
                if(idx%4==0) {
                        team_val == BLUE;
                }
                if(idx%4==1) {
                        team_val == GREEN;
                }
                if(idx%4==2) {
                        team_val == RED;
                }
                if(idx%4==3) {
                        team_val == YELLOW;
                }*/
                idx inside {[0:99]};
        }



endclass

person p_array[100];
int red_c,yellow_c,green_c,blue_c = 0;

initial begin
        foreach (p_array[i]) begin
                p_array[i]=new();
                p_array[i].idx = i;
                p_array[i].randomize();
                p_array[i].name = $sformatf("no_%0d",p_array[i].idx);
                $display("Name:%s Team: %s", p_array[i].name, p_array[i].team_val.name());
                if( p_array[i].team_val == RED) begin
                        red_c++;
                end
                if( p_array[i].team_val == YELLOW) begin
                        yellow_c++;
                end
                if( p_array[i].team_val == GREEN) begin
                        green_c++;
                end
                if( p_array[i].team_val == BLUE) begin
                        blue_c++;
                end
        end
                $display("RED=%d YELLOW=%d GREEN=%d BLUE=%d", red_c,yellow_c,green_c,blue_c);




end
 
