import fire
import re

def loop():
  # problem: recognize food and medicine items for selective taxation
  
  print("Enter a blank line to see total")
  item = input("➡️ ")
  
  billDict =  {"Item":[],"Qty":[],"Price":[]};
  
  while(item !=  ""):
    numbers = re.findall('[0-9]+', item)
    itemstr = re.findall('[^\d ].*[^?= at\d.\d]', item)
    
    if index_exists(numbers, 2):  
      numstr = numbers[1]+'.'+numbers[2]
      itemCost = float(numstr)
      itemTotal = float(numbers[0])*itemCost
      
    else:
      itemCost = float(0) + float(numbers[1])
      itemTotal = float(numbers[0])*itemCost
        
    billDict["Item"].append(itemstr[0])
    billDict["Qty"].append(numbers[0])
    billDict["Price"].append(itemTotal)
    
    item = input("➡️ ")
    
  
  itemTotal = sum(billDict["Price"])
  salesTax = 5
  
  
  print(itemTotal)
  
  return 'bye'

def index_exists(ls, i):
  return (0 <= i < len(ls)) or (-len(ls) <= i < 0)


if __name__ == '__main__':
  fire.Fire(loop)