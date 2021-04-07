import fire
import re

def loop():
  print("Enter a blank line to see total")
  item = input("➡️ ")
  
  stuff = dict()
  
  while(item !=  ""):
    numbers = re.findall('[0-9]+', item)
    if index_exists(numbers, 2):
      numstr = numbers[1]+'.'+numbers[2]
      itemCost = float(numstr)
    else:
      itemCost = float(0) + float(numbers[1])
        
    print ("Item: ", "\nQty:" , numbers[0], "\nPrice: ", itemCost)    
    item = input("➡️ ")
    
  return 'bye'

def index_exists(ls, i):
  return (0 <= i < len(ls)) or (-len(ls) <= i < 0)

if __name__ == '__main__':
  fire.Fire(loop)