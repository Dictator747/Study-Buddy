import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
        ),
      ),
      home: ParentScreen(),
    );
  }
}

class ParentScreen extends StatefulWidget {
  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int screenTime = 0;
  final TextEditingController pinController = TextEditingController();
  String selectedClass = 'Class 1';
  int extendedTime = 1;

  void startSession(int time) {
    setState(() {
      screenTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Study Buddy - Parent Dashboard")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Select Class", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedClass,
                items: List.generate(12, (index) => 'Class ${index + 1}').map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedClass = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              Text("Set Screen Time", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: [
                  for (int time in [5, 10, 15, 20])
                    ElevatedButton(
                      onPressed: () => startSession(time),
                      child: Text("$time mins"),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Text("Selected Time: $screenTime mins", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter 4-digit PIN",
                ),
              ),
              SizedBox(height: 20),
              Text("Select Extra Time per Correct Answer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<int>(
                value: extendedTime,
                items: List.generate(20, (index) => (index + 1)).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value mins"),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    extendedTime = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentScreen(
                      pin: pinController.text,
                      screenTime: screenTime,
                      studentClass: selectedClass,
                      extraTime: extendedTime,
                    ),
                  ),
                ),
                child: Text("Go to Student Screen"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StudentScreen extends StatefulWidget {
  final String pin;
  final int screenTime;
  final String studentClass;
  final int extraTime;

  StudentScreen({required this.pin, required this.screenTime, required this.studentClass, required this.extraTime});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late Timer _timer;
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingTime = widget.screenTime * 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(studentClass: widget.studentClass, extraTime: widget.extraTime)),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Study Buddy - Student Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Class: ${widget.studentClass}"),
            SizedBox(height: 20),
            Text("Remaining Time: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String studentClass;
  final int extraTime;

  QuizScreen({required this.studentClass, required this.extraTime});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int score = 0;
  int remainingTime = 0;

  @override
  void initState() {
    super.initState();
    questions = questionBank[widget.studentClass]!;
    remainingTime = widget.extraTime;
  }

  void checkAnswer(dynamic selectedAnswer) {
    final correctAnswer = questions[currentQuestionIndex]['answer'];
    if (selectedAnswer == correctAnswer) {
      setState(() {
        score++;
        remainingTime += widget.extraTime;  // Adding extra time for correct answers
      });
    }

    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        // When all questions are answered, navigate to result screen
        double percentage = (score / questions.length) * 100;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: score,
              totalQuestions: questions.length,
              percentage: percentage,
            ),
          ),
        );
      }
    });
  }
  final Map<String, List<Map<String, dynamic>>> questionBank = {
    'Class 1': [
      {
        'question': 'What is 1 + 1?', 'options': [2, 3, 4, 5], 'answer': 2
      },
      {
        'question': 'What is 2 + 2?', 'options': [3, 4, 5, 6], 'answer': 4
      },
      {
        'question': 'What is the color of the sky?', 'options': ['Red', 'Blue', 'Yellow', 'Green'], 'answer': 'Blue'
      },
      {
        'question': 'Which animal says "Meow"?', 'options': ['Dog', 'Cat', 'Cow', 'Horse'], 'answer': 'Cat'
      },
      {
        'question': 'Which is the largest animal?', 'options': ['Elephant', 'Whale', 'Lion', 'Tiger'], 'answer': 'Whale'
      },
    ],
    'Class 2': [
      {
        'question': 'What is 5 + 3?', 'options': [6, 7, 8, 9], 'answer': 8
      },
      {
        'question': 'What is 10 - 4?', 'options': [6, 7, 5, 4], 'answer': 6
      },
      {
        'question': 'Which of these is a plant?', 'options': ['Car', 'Tree', 'Bicycle', 'Book'], 'answer': 'Tree'
      },
      {
        'question': 'How many legs does a spider have?', 'options': [6, 8, 10, 12], 'answer': 8
      },
      {
        'question': 'What do plants need to grow?', 'options': ['Water', 'Air', 'Sunlight', 'All of these'], 'answer': 'All of these'
      },
    ],
    'Class 3': [
      {
        'question': 'What is 4 x 6?', 'options': [20, 22, 24, 26], 'answer': 24
      },
      {
        'question': 'What is 15 - 7?', 'options': [6, 7, 8, 9], 'answer': 8
      },
      {
        'question': 'Which is the largest continent?', 'options': ['Africa', 'Asia', 'Europe', 'America'], 'answer': 'Asia'
      },
      {
        'question': 'Which of these is a mammal?', 'options': ['Fish', 'Bird', 'Dog', 'Frog'], 'answer': 'Dog'
      },
      {
        'question': 'What is the main source of energy for the Earth?', 'options': ['Moon', 'Sun', 'Stars', 'Wind'], 'answer': 'Sun'
      },
    ],
    'Class 4': [
      {
        'question': 'What shape has 4 equal sides?', 'options': ['Rectangle', 'Circle', 'Square', 'Triangle'], 'answer': 'Square'
      },
      {
        'question': 'What is 12 x 3?', 'options': [30, 35, 36, 40], 'answer': 36
      },
      {
        'question': 'Which planet is known as the Red Planet?', 'options': ['Earth', 'Mars', 'Jupiter', 'Venus'], 'answer': 'Mars'
      },
      {
        'question': 'What is the capital city of India?', 'options': ['Delhi', 'Mumbai', 'Kolkata', 'Chennai'], 'answer': 'Delhi'
      },
      {
        'question': 'Which country is the Great Wall of China located in?', 'options': ['India', 'China', 'Japan', 'Russia'], 'answer': 'China'
      },
    ],
    'Class 5': [
      {
        'question': 'What is 13 x 7?', 'options': [91, 92, 93, 94], 'answer': 91
      },
      {
        'question': 'What is the nearest planet to the Sun?', 'options': ['Earth', 'Mercury', 'Venus', 'Mars'], 'answer': 'Mercury'
      },
      {
        'question': 'Which of the following is a gas?', 'options': ['Water', 'Oxygen', 'Salt', 'Iron'], 'answer': 'Oxygen'
      },
      {
        'question': 'What is the main function of roots in plants?', 'options': ['Produce flowers', 'Absorb water', 'Store food', 'Make fruits'], 'answer': 'Absorb water'
      },
      {
        'question': 'Which is the largest ocean on Earth?', 'options': ['Atlantic Ocean', 'Pacific Ocean', 'Indian Ocean', 'Arctic Ocean'], 'answer': 'Pacific Ocean'
      },
    ],
    'Class 6': [
      {
        'question': 'What is 1/2 + 1/4?', 'options': ['1/2', '3/4', '1', '5/4'], 'answer': '3/4'
      },
      {
        'question': 'Who was the first President of India?', 'options': ['Jawaharlal Nehru', 'Sardar Patel', 'Dr. Rajendra Prasad', 'Indira Gandhi'], 'answer': 'Dr. Rajendra Prasad'
      },
      {
        'question': 'What is 25% of 100?', 'options': [20, 25, 30, 35], 'answer': 25
      },
      {
        'question': 'Which of these is a renewable resource?', 'options': ['Coal', 'Oil', 'Solar Energy', 'Natural Gas'], 'answer': 'Solar Energy'
      },
      {
        'question': 'In which year did India gain independence?', 'options': ['1942', '1947', '1950', '1952'], 'answer': '1947'
      },
    ],
    'Class 7': [
      {
        'question': 'Solve: x + 7 = 12. What is x?', 'options': [3, 4, 5, 6], 'answer': 5
      },
      {
        'question': 'Which of these is not a source of water?', 'options': ['Rain', 'River', 'Lakes', 'Sun'], 'answer': 'Sun'
      },
      {
        'question': 'What is the largest country in the world?', 'options': ['USA', 'China', 'Russia', 'India'], 'answer': 'Russia'
      },
      {
        'question': 'Who wrote the Indian National Anthem?', 'options': ['Rabindranath Tagore', 'Mahatma Gandhi', 'Subhas Chandra Bose', 'Jawaharlal Nehru'], 'answer': 'Rabindranath Tagore'
      },
      {
        'question': 'What is the atomic number of oxygen?', 'options': [6, 7, 8, 9], 'answer': 8
      },
    ],
    'Class 8': [
      {
        'question': 'What is the ratio of 4 to 8?', 'options': ['1:2', '2:1', '1:1', '3:1'], 'answer': '1:2'
      },
      {
        'question': 'Which is the longest river in India?', 'options': ['Ganga', 'Yamuna', 'Godavari', 'Narmada'], 'answer': 'Ganga'
      },
      {
        'question': 'Who discovered gravity?', 'options': ['Isaac Newton', 'Albert Einstein', 'Galileo', 'Nikola Tesla'], 'answer': 'Isaac Newton'
      },
      {
        'question': 'What is the capital of Tamil Nadu?', 'options': ['Chennai', 'Madurai', 'Coimbatore', 'Trichy'], 'answer': 'Chennai'
      },
      {
        'question': 'How many continents are there?', 'options': [6, 7, 8, 9], 'answer': 7
      },
    ],
    'Class 9': [
      {
        'question': 'Solve: 2x - 3 = 5. What is x?', 'options': [3, 4, 5, 6], 'answer': 4
      },
      {
        'question': 'Which of these was the first battle of independence in India?', 'options': ['Battle of Plassey', 'First War of Independence', 'Battle of Panipat', 'Second Battle of Tarain'], 'answer': 'First War of Independence'
      },
      {
        'question': 'Who was the founder of the Maurya Dynasty?', 'options': ['Chandragupta Maurya', 'Ashoka', 'Bimbisara', 'Bindusara'], 'answer': 'Chandragupta Maurya'
      },
      {
        'question': 'What is the pH value of water?', 'options': [6, 7, 8, 9], 'answer': 7
      },
      {
        'question': 'Which element is most abundant in the Earth’s crust?', 'options': ['Oxygen', 'Iron', 'Silicon', 'Magnesium'], 'answer': 'Oxygen'
      },
    ],
    'Class 10': [
      {
        'question': 'Solve the quadratic equation: x^2 - 5x + 6 = 0', 'options': [1, 2, 3, 4], 'answer': 2
      },
      {
        'question': 'Who was the first woman to become the Prime Minister of India?', 'options': ['Indira Gandhi', 'Sarojini Naidu', 'K. Kamaraj', 'Rajkumari Amrit Kaur'], 'answer': 'Indira Gandhi'
      },
      {
        'question': 'Who is known as the "Father of the Indian Nation"?', 'options': ['Jawaharlal Nehru', 'Mahatma Gandhi', 'Bhagat Singh', 'Subhas Chandra Bose'], 'answer': 'Mahatma Gandhi'
      },
      {
        'question': 'What is the chemical symbol for gold?', 'options': ['Ag', 'Au', 'Fe', 'Pb'], 'answer': 'Au'
      },
      {
        'question': 'What is the atomic number of hydrogen?', 'options': [1, 2, 3, 4], 'answer': 1
      },
    ],
    'Class 11': [
      {
        'question': 'What is the SI unit of force?', 'options': ['Newton', 'Joule', 'Pascal', 'Watt'], 'answer': 'Newton'
      },
      {
        'question': 'Which law states that "Every action has an equal and opposite reaction"?', 'options': ['Newton’s First Law', 'Newton’s Second Law', 'Newton’s Third Law', 'Law of Conservation of Momentum'], 'answer': 'Newton’s Third Law'
      },
      {
        'question': 'What is the value of the acceleration due to gravity on Earth?', 'options': ['9.8 m/s²', '10 m/s²', '8.5 m/s²', '9 m/s²'], 'answer': '9.8 m/s²'
      },
      {
        'question': 'What is the unit of electric current?', 'options': ['Coulomb', 'Ampere', 'Volt', 'Ohm'], 'answer': 'Ampere'
      },
      {
        'question': 'Which of these is a scalar quantity?', 'options': ['Displacement', 'Force', 'Velocity', 'Speed'], 'answer': 'Speed'
      },
      {
        'question': 'What is the chemical formula of methane?', 'options': ['CH4', 'C2H6', 'CO2', 'C3H8'], 'answer': 'CH4'
      },
      {
        'question': 'Which element has the atomic number 6?', 'options': ['Carbon', 'Oxygen', 'Nitrogen', 'Helium'], 'answer': 'Carbon'
      },
      {
        'question': 'Which of the following is an example of a covalent bond?', 'options': ['NaCl', 'H2O', 'NaOH', 'K2SO4'], 'answer': 'H2O'
      },
      {
        'question': 'What is the common name for sodium bicarbonate?', 'options': ['Baking Soda', 'Washing Soda', 'Lime', 'Salt'], 'answer': 'Baking Soda'
      },
      {
        'question': 'What is the pH of pure water?', 'options': [6, 7, 8, 9], 'answer': 7
      },
      {
        'question': 'What is the value of sin(30°)?', 'options': ['1/2', '√3/2', '1', '0'], 'answer': '1/2'
      },
      {
        'question': 'What is the solution of the equation: 2x + 5 = 11?', 'options': [3, 4, 5, 6], 'answer': 3
      },
      {
        'question': 'What is the sum of the first 10 natural numbers?', 'options': [45, 55, 65, 75], 'answer': 55
      },
      {
        'question': 'What is the derivative of x²?', 'options': ['2x', 'x', 'x²', '2'], 'answer': '2x'
      },
      {
        'question': 'Which of the following is a Pythagorean triplet?', 'options': ['3, 4, 5', '1, 2, 3', '5, 7, 8', '6, 8, 10'], 'answer': '3, 4, 5'
      },
    ],
    'Class 12': [
      {
        'question': 'What is the unit of electric charge?', 'options': ['Coulomb', 'Ampere', 'Volt', 'Ohm'], 'answer': 'Coulomb'
      },
      {
        'question': 'What is the formula for kinetic energy?', 'options': ['1/2 mv²', 'mv', 'mgh', '1/2 m²v'], 'answer': '1/2 mv²'
      },
      {
        'question': 'Which of these is the SI unit of power?', 'options': ['Watt', 'Joule', 'Newton', 'Volt'], 'answer': 'Watt'
      },
      {
        'question': 'Which is the correct unit for resistance?', 'options': ['Volt', 'Ohm', 'Ampere', 'Joule'], 'answer': 'Ohm'
      },
      {
        'question': 'What does the law of conservation of energy state?', 'options': ['Energy can be created', 'Energy can be destroyed', 'Energy can be converted from one form to another', 'Energy cannot be converted'], 'answer': 'Energy can be converted from one form to another'
      },
      {
        'question': 'What is the IUPAC name of C2H6?', 'options': ['Methane', 'Ethane', 'Propane', 'Butane'], 'answer': 'Ethane'
      },
      {
        'question': 'What is the chemical formula of sulfuric acid?', 'options': ['H2SO4', 'HCl', 'NaOH', 'H2CO3'], 'answer': 'H2SO4'
      },
      {
        'question': 'Which of these is an example of an exothermic reaction?', 'options': ['Combustion', 'Photosynthesis', 'Melting of ice', 'Boiling of water'], 'answer': 'Combustion'
      },
      {
        'question': 'Which element is most abundant in the Earth\'s crust?', 'options': ['Oxygen', 'Silicon', 'Iron', 'Magnesium'], 'answer': 'Oxygen'
      },
      {
        'question': 'What is the oxidation state of chlorine in HClO4?', 'options': [1, 3, 5, 7], 'answer': 7
      },
      {
        'question': 'What is the solution to the equation: 2x² + 5x + 3 = 0?', 'options': ['-1, 3/2', '1, -3', '1/2, -3', '3/2, -1'], 'answer': '-1, 3/2'
      },
      {
        'question': 'What is the value of the integral ∫x dx?', 'options': ['x²/2', '2x²', 'x³/3', 'x²'], 'answer': 'x²/2'
      },
      {
        'question': 'What is the derivative of sin(x)?', 'options': ['cos(x)', '-cos(x)', 'sin(x)', '-sin(x)'], 'answer': 'cos(x)'
      },
      {
        'question': 'What is the sum of the first 100 natural numbers?', 'options': [5050, 10000, 5000, 505], 'answer': 5050
      },
      {
        'question': 'What is the value of cos(60°)?', 'options': ['1', '1/2', '√2/2', '0'], 'answer': '1/2'
      },
    ]};

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz for ${widget.studentClass}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question['question'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...question['options'].map((option) {
              return ElevatedButton(
                onPressed: () => checkAnswer(option),
                child: Text(option.toString()),
              );
            }).toList(),
            SizedBox(height: 20),
            Text("Remaining Time: $remainingTime minutes"),
          ],
        ),
      ),
    );
  }
}


class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final double percentage;

  ResultScreen({
    required this.score,
    required this.totalQuestions,
    required this.percentage,
  });

  String getFeedback() {
    if (percentage >= 90) {
      return "Excellent!";
    } else if (percentage >= 75) {
      return "Good Job!";
    } else if (percentage >= 50) {
      return "Needs Improvement";
    } else {
      return "Better Luck Next Time!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Score: $score / $totalQuestions",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "Percentage: ${percentage.toStringAsFixed(2)}%",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                getFeedback(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: getFeedbackColor(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the parent screen
                },
                child: Text("Back to Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getFeedbackColor() {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.blue;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}