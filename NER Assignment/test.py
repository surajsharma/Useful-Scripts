import fire
import re
import spacy

def loop():
  # problem: recognize food and medicine items for selective taxation
  # problem: do this with named entity recognition
  # problem: how to make spacy recognize books, medical items?
  
  
  nlp = spacy.load("en")
  
  print("Enter a blank line to see total")
  item = input("➡️ ")
  
  billDict =  {"Item":[],"Qty":[],"Price":[]};
  
  dox = nlp(item)
  
  nouns = [[x.text, x.pos_] for x in dox if x.pos_ == 'NOUN']
  for n in nouns:
    print(n)
    
    
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
    dox = nlp(item)
    
    nouns = [[x.text, x.pos_] for x in dox if x.pos_ == 'NOUN']
    
    for n in nouns:
      print(n)
      
  itemTotal = sum(billDict["Price"])
  salesTax = 5
  
  
  print("Total: ",itemTotal)
  
  return 'bye'

def index_exists(ls, i):
  return (0 <= i < len(ls)) or (-len(ls) <= i < 0)


if __name__ == '__main__':
  fire.Fire(loop)