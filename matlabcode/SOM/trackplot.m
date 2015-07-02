function [count] = trackplot(start,n,qe,printedbytes)
  l = length(qe);
  elap_t = etime(clock,start); 
  tot_t = elap_t*l/n;
  % Carriage return does not work as it should (even on UNIX) when printing
  % to screen, so let's do this instead
  fprintf(1, repmat('\b', 1, printedbytes));
  count = fprintf(1,'Training: %3.0f/ %3.0f s \n',elap_t,tot_t);  
  
  plot(1:n,qe(1:n),(n+1):l,qe((n+1):l));
  title('Quantization error after each epoch');
  drawnow      

end