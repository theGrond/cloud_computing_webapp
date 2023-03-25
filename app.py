from azure.core.credentials import AzureKeyCredential
from azure.ai.language.questionanswering import QuestionAnsweringClient
from azure.ai.language.questionanswering import models as qna
from flask import Flask, current_app, render_template, request
from pymongo import MongoClient

endpoint = "https://cloud-computing-qa.cognitiveservices.azure.com/"
credential = AzureKeyCredential("422040cb72d243449ca1a23834532900")

client = MongoClient('mongodb://max-cosmosdb-account:O6FvWPVjizpsTwET3WftAmihvdVKsPcX7pt6zQhVVn3v09FRgarZsWaI5CLLErbOiFrmXcpRbk1iACDb9iRqNQ==@max-cosmosdb-account.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@max-cosmosdb-account@')
db = client['my-mongo-db']
collection = db['qa_collection']

def getAnswer(text, question):
    query = {'text': text, 'question': question}
    if collection.count_documents(query) > 0:
        print("Entry exists in collection")
        return collection.find_one(query)['answer']
    else:
        print("Entry does not exist in collection")
        client = QuestionAnsweringClient(endpoint, credential)
        with client:
            input = qna.AnswersFromTextOptions(
                question=question,
                text_documents=[
                    text
                ]
            )
            output = client.get_answers_from_text(input)
        best_answer = output.answers[0]
        print("Confidence Score: {}".format(output.answers[0].confidence))
        collection.insert_one({"text": text, "question": question, "answer": best_answer.answer})
        return best_answer.answer

app = Flask(__name__)

@app.route('/getAnswer', methods=['POST'])
def process_text():
    data = request.json
    text = data['text']
    question = data['question']
    print("Text: "+text+"\nQuestion: "+question)
    answer = getAnswer(text, question)
    return answer

@app.route('/')
def accessSite():
    return render_template('index.html')