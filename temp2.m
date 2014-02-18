n=16
p=0.7
y=12

l=factorial(n)/(factorial(y)*factorial(n-y));
m=p^y
r=(1-p)^(n-y)

P=l*m*r