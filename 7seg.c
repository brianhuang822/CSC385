#include <stdio.h>
#include <math.h>

int convBinToDec (long long n);

int main(long long n){
	int dec;
	int hex;
	
	dec = convBinToDec(n);
	hex = getHex(dec);
}
int convBinToDec (long long n) {
	int dec = 0;
	int i = 0;
	int remainder;
	while(n!=0) {
		remainder = n%10;
		n /= 10;
		dec += remainder*pow(2, i);
		++i;
	}
	return dec;
}

int getHex (int decNum) {
	long int quotient;
	int i=1;
	int j, temp;
	char hex[100];
	
	quotient = decNum;
	while(quotient!=0) {
		temp = quotient % 16;
		
		if(temp<10)
			temp+=48;
		else
			temp+=55;
		
		hex[i++]=temp;
		quotient = quotient/16;
	}
	for(j=i-1; j>0;j--)
		printf("%c \n", hex[j]);
	return 0;
}