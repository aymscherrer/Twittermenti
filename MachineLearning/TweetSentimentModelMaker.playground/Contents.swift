import Cocoa
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/aymericscherrer/Downloads/twitter-sanders-apple3.csv"))

let(trainingData, testingData) = data.randomSplit(by: 0.8, seed: 0)

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")

let evaluationMetrics = sentimentClassifier.evaluation(on: testingData)

let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100

let metadata = MLModelMetadata(author: "Aymeric Scherrer", shortDescription: "A model trained to classify sentiment on Tweets", version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/aymericscherrer/Downloads/TweetSentimentClassifier.mlmodel"))

// Testing the model, should be Neg
try sentimentClassifier.prediction(from: "@Apple is a terrible company!")

// Testing the model, should be Pos
try sentimentClassifier.prediction(from: "I had a beautiful day!")

// Testing the model, should be Neutral
try sentimentClassifier.prediction(from: "I think @Apple ads are ok.")
