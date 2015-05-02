function [Output] = MovingWinFeats(x, fs, winLen, winDisp, featFn)
% MovingWinFeats(y,100,0.5,0.25,LLFn) - EVERYTHING IS IN SECONDS
NumWins = @(xLen,fs,winLen,winDisp) floor(((xLen) - (winLen*fs))/(winDisp*fs))+1;
i = 1;
j = fs*winLen;

numwins = NumWins(length(x),fs, winLen, winDisp);

for n=1:numwins
    Output(1,n)=featFn(x(i:j));
    i= i+fs*winDisp;
    j= j+fs*winDisp;
end
end

