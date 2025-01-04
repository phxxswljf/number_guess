
 add_fsm_encoding \
       {mp3_player.state} \
       { }  \
       {{000 00} {001 01} {010 10} {100 11} }

 add_fsm_encoding \
       {top.current_state} \
       { }  \
       {{000 000} {001 001} {010 010} {011 011} {100 101} {101 100} }
