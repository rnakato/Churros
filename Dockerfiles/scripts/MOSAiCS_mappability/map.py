import CountMap

window_size = 1000000

for i in xrange(1,26):
        if i <= 22:
                chr = str(i)
        elif i == 23:
                chr = "M"
        elif i == 24:
                chr = "X"
	elif i == 25:
		chr = "Y"

	nicechr = "chr" + chr

	filename = "chr" + chr + "b.out"
	cm=CountMap.CountMap(filename)

	count  = 0	
	for j in xrange(1,250000001):
		
		try:
			x = cm.cnt(j)
			flag = 0
		except ValueError:
			flag = 1
		if flag == 0:
			if x == 1:
				count += 1			

		if j % window_size == 0:
			window = int (j / window_size) - 1
			outstring = nicechr + "\t" + str(window) + "\t" + str(count)
		        print outstring
			count = 0





