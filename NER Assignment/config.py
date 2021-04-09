import spacy

nlp = spacy.load("en")
doc = nlp(u"Hello World")
print(doc.text)