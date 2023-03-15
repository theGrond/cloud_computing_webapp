import os
from azure.core.credentials import AzureKeyCredential
from azure.ai.language.questionanswering import QuestionAnsweringClient
from azure.ai.language.questionanswering import models as qna
from flask import Flask, current_app, render_template, request

endpoint = "https://cloud-computing-qa.cognitiveservices.azure.com/"
credential = AzureKeyCredential("422040cb72d243449ca1a23834532900")

def getAnswer(text, question):
    client = QuestionAnsweringClient(endpoint, credential)
    with client:
        # question="who was darth plagueis?"#"How long does it takes to charge a surface?"
        input = qna.AnswersFromTextOptions(
            question=question,
            text_documents=[
                text
            ]
        )
        output = client.get_answers_from_text(input)

    best_answer = output.answers[0]
    print(u"Q: {}".format(input.question))
    print(u"A: {}".format(best_answer.answer))
    print("Confidence Score: {}".format(output.answers[0].confidence))

    return best_answer.answer

# if __name__ == '__main__':
    # main()

def getBest(a):
  return a.confidence

app = Flask(__name__)

@app.route('/getAnswer', methods=['POST'])
def process_text():
    data = request.json

    text = data['text']
    question = data['question']
    print("Text: "+text+"\nQuestion: "+question)
    
    answer = getAnswer(text, question)

    return answer
  #return "Text 1: {}\nText 2: {}".format(text1, text2)

@app.route('/')
def accessSite():
    return render_template('index.html')

