function preresolve(dq)

	-- note that the comparisons below are CaSe InSensiTivE and you don't have to worry about trailing dots
	if(dq.qname:equal("ns1.test2.ba"))
	then
                if dq.qtype == pdns.A then
	              dq:addAnswer(pdns.A, "8.8.8.8")
        	      --dq:addAnswer(pdns.TXT, "\"Hello!\"", 3601) -- ttl
                      return true;
                end    	
		print("test2!")
	end

	return false; 
end
