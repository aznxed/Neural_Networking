// Daniel Shiffman and now edited by Ambrose Douglas
// The Nature of Code, Fall 2006
// Neural Network

// Class to describe the entire network
// Arrays for input neurons, hidden neurons, and output neuron

// Need to update this so that it would work with an array out outputs
// Rather silly that I didn't do this initially

// Also need to build in a "Layer" class so that there can easily
// be more than one hidden layer

import java.util.ArrayList;

public class Network {

  // Layers
  InputNeuron[] input;
  HiddenNeuron[] hidden;
  OutputNeuron[] output;
  float[] answerOutput;

  public static final float LEARNING_CONSTANT = 0.5f;

  // Only One output now to start!!! (i can do better, really. . .)
  // Constructor makes the entire network based on number of inputs & number of neurons in hidden layer
  // Only One hidden layer!!!  (fix this dood)

  public Network(int inputs, int hiddentotal, int outputtotal) {

    input = new InputNeuron[inputs+1];  // Got to add a bias input
    hidden = new HiddenNeuron[hiddentotal+1];
    output = new OutputNeuron[outputtotal]; // does outputs need bias +1

    // Make input neurons
    for (int i = 0; i < input.length-1; i++) {
      input[i] = new InputNeuron();
    }

    // Make hidden neurons
    for (int i = 0; i < hidden.length-1; i++) {
      hidden[i] = new HiddenNeuron();
    }

    // Output neurons do not need a bias
    for (int i = 0; i < output.length; i++) {
      output[i] = new OutputNeuron();
    }
    // Make bias neurons
    input[input.length-1] = new InputNeuron(1);
    hidden[hidden.length-1] = new HiddenNeuron(1);

    // Make output neuron
    //output = new OutputNeuron();

    // Connect input layer to hidden layer
    for (int i = 0; i < input.length; i++) {
      for (int j = 0; j < hidden.length-1; j++) {
        // Create the connection object and put it in both neurons
        Connection c = new Connection(input[i], hidden[j]);
        input[i].addConnection(c);
        hidden[j].addConnection(c);
      }
    }

    println("made it here");
    // Connect the hidden layer to the output neuron
    for (int i = 0; i < hidden.length; i++) {
      println("before");
      for (int j = 0; j < output.length; j++)
      {
        println("or here"); //<>//
        println(hidden.length);
        println(output.length);
        println("i; " +i);
        println("j: " +j);
        Connection c = new Connection(hidden[i], output[j]); //<>//
        println("first");
        hidden[i].addConnection(c);
        println("sec");
        output[j].addConnection(c);
        println("thr");
      }
    }
  }


  public float[] feedForward(float[] inputVals) {

    // Feed the input with an array of inputs
    for (int i = 0; i < inputVals.length; i++) {
      input[i].input(inputVals[i]);
    }

    // Have the hidden layer calculate its output
    for (int i = 0; i < hidden.length-1; i++) {
      hidden[i].calcOutput();
    }

    // Calculate the output of the output neuron
    for (int i = 0; i < output.length; i++) {
      output[i].calcOutput();
    }

    // Return output
    answerOutput = new float[output.length];  // ASK TYLER IF THIS IS A BAD IDEA
    for (int i = 0; i < output.length; i++) {
      answerOutput[i] = output[i].getOutput();
    }

    return answerOutput;
  }


  public float[] train(float[] inputs, float[] answers) {
    float[] results = feedForward(inputs);
    //float[] deltaOutput = new float[results.length];
    ArrayList connections;


    // This is where the error correction all starts
    // Derivative of sigmoid output function * diff between known and guess
    for ( int i = 0; i < answers.length; i++) {
      output[i].deltaOutput = results[i]*(1-results[i]) * (answers[i]-results[i]);
    }

    // BACKPROPOGATION
    // This is easier b/c we just have one output
    // Apply Delta to connections between hidden and output


    for (int i = 0; i < output.length; i++) {
      connections = output[i].getConnections();
      for (int j = 0; j < connections.size(); j++) {
        Connection c = (Connection) connections.get(j);
        Neuron neuron = c.getFrom();
        float output_ = neuron.getOutput();
        float deltaWeight = output_*output[i].deltaOutput;
        c.adjustWeight(LEARNING_CONSTANT*deltaWeight);
      }
    }

    // ADJUST HIDDEN WEIGHTS
    for (int i = 0; i < hidden.length; i++) {
      connections = hidden[i].getConnections();
      float sum  = 0;
      // Sum output delta * hidden layer connections (just one output)
      for (int j = 0; j < connections.size(); j++) {
        Connection c = (Connection) connections.get(j);
        // Is this a connection from hidden layer to next layer (output)?
        if (c.getFrom() == hidden[i]) {
          OutputNeuron To = (OutputNeuron) c.getTo();
          sum += c.getWeight()*To.getDeltaOutput(); //deltaOutput must be attributed to a certain output neurode
        }
      }    
      // Then adjust the weights coming in based:
      // Above sum * derivative of sigmoid output function for hidden neurons
      for (int j = 0; j < connections.size(); j++) {
        Connection c = (Connection) connections.get(j);
        // Is this a connection from previous layer (input) to hidden layer?
        if (c.getTo() == hidden[i]) {
          float output = hidden[i].getOutput();
          float deltaHidden = output * (1 - output);  // Derivative of sigmoid(x)
          deltaHidden *= sum;   // Would sum for all outputs if more than one output
          Neuron neuron = c.getFrom();
          float deltaWeight = neuron.getOutput()*deltaHidden;
          c.adjustWeight(LEARNING_CONSTANT*deltaWeight);
        }
      }
    }

    return results;
  }
}