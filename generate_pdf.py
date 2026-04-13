from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    HRFlowable, KeepTogether
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER

OUTPUT = "/Users/abdullahsaber/Documents/Claude/task_manager/Task_Manager_App_Study_Guide.pdf"

# ── Colours ──────────────────────────────────────────────────────────────────
INDIGO      = colors.HexColor("#6366F1")
INDIGO_LIGHT= colors.HexColor("#EEF2FF")
DARK        = colors.HexColor("#1E1B4B")
GREY        = colors.HexColor("#6B7280")
GREEN       = colors.HexColor("#16A34A")
GREEN_BG    = colors.HexColor("#F0FDF4")
ORANGE      = colors.HexColor("#EA580C")
ORANGE_BG   = colors.HexColor("#FFF7ED")
RED         = colors.HexColor("#DC2626")
RED_BG      = colors.HexColor("#FEF2F2")
CODE_BG     = colors.HexColor("#F1F5F9")
WHITE       = colors.white

# ── Styles ───────────────────────────────────────────────────────────────────
base = getSampleStyleSheet()

def style(name, parent="Normal", **kw):
    return ParagraphStyle(name, parent=base[parent], **kw)

H1 = style("H1", "Title",
    fontSize=26, textColor=DARK, spaceAfter=6, spaceBefore=0,
    fontName="Helvetica-Bold", alignment=TA_CENTER)

H2 = style("H2",
    fontSize=15, textColor=WHITE, spaceAfter=4, spaceBefore=14,
    fontName="Helvetica-Bold", backColor=INDIGO,
    borderPadding=(6, 10, 6, 10), alignment=TA_LEFT)

H3 = style("H3",
    fontSize=12, textColor=INDIGO, spaceAfter=3, spaceBefore=8,
    fontName="Helvetica-Bold")

BODY = style("BODY",
    fontSize=10, textColor=colors.HexColor("#374151"),
    spaceAfter=5, leading=15)

BULLET = style("BULLET",
    fontSize=10, textColor=colors.HexColor("#374151"),
    spaceAfter=3, leading=14, leftIndent=14,
    bulletIndent=4)

CODE = style("CODE",
    fontSize=9, fontName="Courier",
    textColor=colors.HexColor("#1E293B"),
    backColor=CODE_BG, leading=13,
    leftIndent=10, rightIndent=10,
    spaceAfter=6, spaceBefore=2,
    borderPadding=(6, 8, 6, 8))

Q = style("Q",
    fontSize=11, textColor=DARK,
    fontName="Helvetica-Bold", spaceAfter=3, spaceBefore=8)

A = style("A",
    fontSize=10, textColor=colors.HexColor("#374151"),
    spaceAfter=6, leading=15, leftIndent=10)

SUBTITLE = style("SUBTITLE",
    fontSize=12, textColor=GREY,
    alignment=TA_CENTER, spaceAfter=20)

TIP = style("TIP",
    fontSize=10, textColor=GREEN,
    fontName="Helvetica-Bold", spaceAfter=2)

WARN = style("WARN",
    fontSize=10, textColor=ORANGE,
    fontName="Helvetica-Bold", spaceAfter=2)

# ── Helpers ───────────────────────────────────────────────────────────────────
def b(text):  return f"<b>{text}</b>"
def i(text):  return f"<i>{text}</i>"
def c(text):  return f'<font name="Courier" size="9">{text}</font>'
def col(text, color): return f'<font color="{color}">{text}</font>'

def hr():
    return HRFlowable(width="100%", thickness=1,
                      color=colors.HexColor("#E5E7EB"), spaceAfter=6, spaceBefore=6)

def section(title):
    return Paragraph(f"  {title}", H2)

def tip_box(label, text, bg=GREEN_BG, label_color=GREEN):
    data = [[Paragraph(f'<font color="{label_color}"><b>{label}</b></font> {text}', BODY)]]
    t = Table(data, colWidths=[16*cm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (-1,-1), bg),
        ("ROUNDEDCORNERS", [6]),
        ("TOPPADDING",  (0,0), (-1,-1), 8),
        ("BOTTOMPADDING",(0,0),(-1,-1), 8),
        ("LEFTPADDING", (0,0), (-1,-1), 12),
        ("RIGHTPADDING",(0,0), (-1,-1), 12),
    ]))
    return t

def two_col_table(rows, col1_w=5*cm, col2_w=11.5*cm):
    data = [[Paragraph(b(r[0]), BODY), Paragraph(r[1], BODY)] for r in rows]
    t = Table(data, colWidths=[col1_w, col2_w])
    t.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (0,-1), INDIGO_LIGHT),
        ("TEXTCOLOR",     (0,0), (0,-1), INDIGO),
        ("FONTNAME",      (0,0), (0,-1), "Helvetica-Bold"),
        ("FONTSIZE",      (0,0), (-1,-1), 9),
        ("GRID",          (0,0), (-1,-1), 0.5, colors.HexColor("#E5E7EB")),
        ("TOPPADDING",    (0,0), (-1,-1), 6),
        ("BOTTOMPADDING", (0,0), (-1,-1), 6),
        ("LEFTPADDING",   (0,0), (-1,-1), 8),
        ("VALIGN",        (0,0), (-1,-1), "TOP"),
    ]))
    return t

def qa(question, answer):
    return KeepTogether([
        Paragraph(f"Q: {question}", Q),
        Paragraph(f"A: {answer}", A),
    ])

# ── Content ───────────────────────────────────────────────────────────────────
story = []

# ── Cover ─────────────────────────────────────────────────────────────────────
story += [
    Spacer(1, 1.5*cm),
    Paragraph("Task Manager App", H1),
    Paragraph("Interview Study Guide", SUBTITLE),
    hr(),
    Spacer(1, 0.3*cm),
    tip_box("What is this?",
        "A Flutter mobile app that lets users log in and manage tasks (create, read, update, delete) "
        "through a REST API. Built as a junior-level CRUD project."),
    Spacer(1, 0.5*cm),
]

# ── 1. Tech Stack ─────────────────────────────────────────────────────────────
story += [
    section("1. Tech Stack"),
    Spacer(1, 0.2*cm),
    two_col_table([
        ("Flutter",           "UI framework by Google. Write one codebase, run on iOS, Android, and Web."),
        ("Dart",              "Programming language Flutter uses. Similar to Java/JavaScript."),
        ("http package",      "Makes network requests (GET, POST, PUT, DELETE) to the REST API."),
        ("SharedPreferences", "Saves small data (like the login token) directly on the device."),
        ("Provider",          "State management. Used only for login/logout state across the app."),
        ("intl",              "Formats dates nicely, e.g. 'April 8, 2026'."),
        ("json-server",       "Mock backend API. Runs locally, stores data in db.json file."),
        ("json-server-auth",  "Adds login/register endpoints to json-server with JWT tokens."),
    ]),
    Spacer(1, 0.3*cm),
]

# ── 2. Folder Structure ───────────────────────────────────────────────────────
story += [
    section("2. Folder Structure"),
    Spacer(1, 0.2*cm),
    Paragraph("The project follows a simple, flat structure — one folder per concern:", BODY),
    Spacer(1, 0.1*cm),
    Paragraph("""lib/<br/>
&nbsp;&nbsp;main.dart &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;← App entry point, Provider setup, routing<br/>
&nbsp;&nbsp;models/<br/>
&nbsp;&nbsp;&nbsp;&nbsp;task.dart &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;← Task data class (fromJson / toJson)<br/>
&nbsp;&nbsp;services/<br/>
&nbsp;&nbsp;&nbsp;&nbsp;auth_service.dart &nbsp;&nbsp;&nbsp;&nbsp;← Login, logout, token storage<br/>
&nbsp;&nbsp;&nbsp;&nbsp;api_service.dart &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;← All HTTP calls (GET/POST/PUT/DELETE)<br/>
&nbsp;&nbsp;screens/<br/>
&nbsp;&nbsp;&nbsp;&nbsp;login_screen.dart &nbsp;&nbsp;&nbsp;&nbsp;← Email + password form<br/>
&nbsp;&nbsp;&nbsp;&nbsp;task_list_screen.dart ← Task list with search and filter chips<br/>
&nbsp;&nbsp;&nbsp;&nbsp;task_detail_screen.dart← Full task view with edit/delete<br/>
&nbsp;&nbsp;&nbsp;&nbsp;task_form_screen.dart ← Create AND edit form (same screen)<br/>
&nbsp;&nbsp;widgets/<br/>
&nbsp;&nbsp;&nbsp;&nbsp;task_card.dart &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;← Reusable card shown in the list""", CODE),
    Spacer(1, 0.2*cm),
    tip_box("Why this structure?",
        "One folder per layer. Models hold data, services talk to the API, screens are what the user "
        "sees, widgets are reusable UI pieces. Easy to find any file in under 5 seconds."),
    Spacer(1, 0.3*cm),
]

# ── 3. Authentication Flow ────────────────────────────────────────────────────
story += [
    section("3. Authentication Flow"),
    Spacer(1, 0.2*cm),
    Paragraph(b("How login works — step by step:"), H3),
    Paragraph("1. User opens the app.", BULLET),
    Paragraph("2. " + c("main.dart") + " calls " + c("authService.loadToken()") +
              " — checks if a token was saved from last session.", BULLET),
    Paragraph("3. If token exists → go straight to Task List screen. If not → show Login screen.", BULLET),
    Paragraph("4. User enters email + password and taps Login.", BULLET),
    Paragraph("5. App sends " + c("POST /login") + " to the API with email and password.", BULLET),
    Paragraph("6. API returns " + c('{ "accessToken": "eyJ..." }') + ".", BULLET),
    Paragraph("7. Token is saved in " + b("SharedPreferences") + " (stays after app restart) and in memory.", BULLET),
    Paragraph("8. " + c("notifyListeners()") + " is called → " + c("Consumer<AuthService>") +
              " in main.dart rebuilds → navigates to Task List.", BULLET),
    Paragraph("9. Every API request after that attaches " + c("Authorization: Bearer <token>") +
              " in the header.", BULLET),
    Spacer(1, 0.2*cm),
    Paragraph(b("How logout works:"), H3),
    Paragraph("Tapping logout calls " + c("authService.logout()") + " which clears the token from "
              "both memory and SharedPreferences, then " + c("notifyListeners()") +
              " triggers a rebuild back to the Login screen.", BODY),
    Spacer(1, 0.2*cm),
    tip_box("Key file", c("lib/services/auth_service.dart") +
            " — contains login(), logout(), and loadToken(). "
            "It extends ChangeNotifier so the UI reacts when login state changes."),
    Spacer(1, 0.3*cm),
]

# ── 4. Task Model ─────────────────────────────────────────────────────────────
story += [
    section("4. Task Model"),
    Spacer(1, 0.2*cm),
    Paragraph("The Task class in " + c("lib/models/task.dart") +
              " is the blueprint for a task object. Every piece of task data "
              "in the app is a Task object.", BODY),
    Spacer(1, 0.1*cm),
    two_col_table([
        ("id",           "Unique identifier. Comes from the API as a number, stored as String."),
        ("title",        "Required. The name of the task."),
        ("description",  "Optional (nullable). Extra details about the task."),
        ("status",       "One of: 'todo', 'in_progress', 'done'."),
        ("priority",     "One of: 'low', 'medium', 'high'."),
        ("dueDate",      "Optional DateTime. The deadline for the task."),
        ("assignedTo",   "Optional String. Name of the person responsible."),
    ], col1_w=3.5*cm, col2_w=13*cm),
    Spacer(1, 0.2*cm),
    Paragraph(b("Two key methods:"), H3),
    Paragraph(c("Task.fromJson(json)") + " — converts the raw Map the API returns into a typed Task object.", BULLET),
    Paragraph(c("task.toJson()") + " — converts a Task object back into a Map to send to the API.", BULLET),
    Paragraph(c("task.copyWith(...)") + " — returns a copy of the task with specific fields changed. Used when editing.", BULLET),
    Spacer(1, 0.3*cm),
]

# ── 5. API Service ────────────────────────────────────────────────────────────
story += [
    section("5. API Service"),
    Spacer(1, 0.2*cm),
    Paragraph("All HTTP calls live in one file: " + c("lib/services/api_service.dart") +
              ". This keeps networking code in one place and out of the UI.", BODY),
    Spacer(1, 0.2*cm),
    two_col_table([
        ("getTasks()",     "GET /tasks — fetches all tasks. Accepts optional filters: status, priority, search query."),
        ("getTask(id)",    "GET /tasks/:id — fetches one task by ID."),
        ("createTask()",   "POST /tasks — sends a new task to the API. Returns the created task with its ID."),
        ("updateTask()",   "PUT /tasks/:id — sends updated task data. Returns the updated task."),
        ("deleteTask(id)", "DELETE /tasks/:id — deletes a task. Returns nothing (204 No Content)."),
    ], col1_w=4*cm, col2_w=12.5*cm),
    Spacer(1, 0.2*cm),
    Paragraph(b("How the token is attached automatically:"), H3),
    Paragraph("The service has a " + c("_headers") + " getter that builds the header Map with "
              + c("Authorization: Bearer token") + " every time. Every method passes this to the request. "
              "You never have to remember to add it manually.", BODY),
    Paragraph(b("How errors are handled:"), H3),
    Paragraph("A helper method " + c("_checkResponse()") + " runs after every request. "
              "If the status code is not 2xx, it throws an Exception with a readable message. "
              "The screen catches this and shows a red snackbar to the user.", BODY),
    Spacer(1, 0.3*cm),
]

# ── 6. State Management ───────────────────────────────────────────────────────
story += [
    section("6. State Management"),
    Spacer(1, 0.2*cm),
    Paragraph(b("Two types of state in this app:"), H3),
    Spacer(1, 0.1*cm),
    two_col_table([
        ("Local state\n(setState)",
         "Used inside each screen for things only that screen cares about: "
         "loading spinners, form values, the task list, error messages. "
         "Simple and direct — just call setState() to rebuild the widget."),
        ("Global state\n(Provider)",
         "Used only for authentication. AuthService extends ChangeNotifier. "
         "When login/logout happens, notifyListeners() is called and any widget "
         "using Consumer<AuthService> automatically rebuilds — like the routing in main.dart."),
    ], col1_w=3.5*cm, col2_w=13*cm),
    Spacer(1, 0.2*cm),
    tip_box("Why not Bloc/Riverpod?",
        "This app is junior-level. setState for local UI state and Provider for one global concern "
        "(auth) is exactly the right amount of complexity. Bloc would add unnecessary boilerplate "
        "for a simple CRUD app."),
    Spacer(1, 0.3*cm),
]

# ── 7. Screens ────────────────────────────────────────────────────────────────
story += [
    section("7. Screens — What Each One Does"),
    Spacer(1, 0.2*cm),
]

screens = [
    ("Login Screen",        "login_screen.dart",
     "Email + password form. Validates input before sending. Shows a spinner on the button "
     "while waiting for the API. Shows a red snackbar on error. On success, the Consumer in "
     "main.dart automatically navigates to the task list."),
    ("Task List Screen",    "task_list_screen.dart",
     "Main screen after login. Loads all tasks from the API on startup. Has a search bar "
     "(filters by title as you type) and filter chips for status and priority. "
     "Pull-to-refresh reloads from API. FAB (Floating Action Button) opens the create form. "
     "Tapping a card opens the detail screen."),
    ("Task Detail Screen",  "task_detail_screen.dart",
     "Read-only view of a single task. Shows title, status badge, priority badge, "
     "description, assigned user, and due date. Edit icon opens the form in edit mode. "
     "Delete icon shows a confirmation dialog then deletes via API."),
    ("Task Form Screen",    "task_form_screen.dart",
     "Dual-purpose screen: if a Task is passed in, it pre-fills the form (edit mode). "
     "If nothing is passed, it shows a blank form (create mode). Has dropdowns for "
     "status and priority, a date picker for due date, and a text field for assigned user. "
     "Saves via POST (create) or PUT (edit)."),
]

for name, file, desc in screens:
    story += [
        Paragraph(b(name) + f"  {c(file)}", H3),
        Paragraph(desc, BODY),
    ]

story += [
    Paragraph(b("Task Card Widget") + f"  {c('task_card.dart')}", H3),
    Paragraph("Reusable widget shown in the list. Displays title, description preview, "
              "priority badge (coloured), status badge, due date, and a circle avatar with "
              "the first letter of the assigned user's name.", BODY),
    Spacer(1, 0.3*cm),
]

# ── 8. Data Flow ──────────────────────────────────────────────────────────────
story += [
    section("8. Data Flow — How It All Connects"),
    Spacer(1, 0.2*cm),
    Paragraph("Here is the full journey of a user action — tapping 'New Task' and saving:", BODY),
    Spacer(1, 0.1*cm),
    Paragraph("1. User taps the + New Task button on Task List screen.", BULLET),
    Paragraph("2. " + c("Navigator.push") + " opens " + c("TaskFormScreen") + " with no task argument (create mode).", BULLET),
    Paragraph("3. User fills in the form and taps Save.", BULLET),
    Paragraph("4. " + c("_save()") + " validates the form. If invalid, shows error under the field.", BULLET),
    Paragraph("5. A " + c("Task") + " object is created from the form values.", BULLET),
    Paragraph("6. " + c("apiService.createTask(task)") + " is called — sends " +
              c("POST /tasks") + " with " + c("task.toJson()") + " as the body.", BULLET),
    Paragraph("7. API returns the created task JSON with the new ID.", BULLET),
    Paragraph("8. " + c("Task.fromJson()") + " converts the response back into a Task object.", BULLET),
    Paragraph("9. " + c("Navigator.pop(context, true)") + " goes back to the list.", BULLET),
    Paragraph("10. Task List screen sees " + c("true") + " was returned and calls " +
              c("_loadTasks()") + " to refresh.", BULLET),
    Spacer(1, 0.3*cm),
]

# ── 9. Mock API ───────────────────────────────────────────────────────────────
story += [
    section("9. Mock API (json-server)"),
    Spacer(1, 0.2*cm),
    Paragraph(b("What is json-server?"), H3),
    Paragraph("A tool that turns a JSON file (" + c("db.json") + ") into a full REST API automatically. "
              "No real backend code needed. Perfect for frontend development and testing.", BODY),
    Spacer(1, 0.1*cm),
    two_col_table([
        ("db.json",     "The 'database'. An array of users and an array of tasks. json-server reads/writes this file."),
        ("routes.json", "Route configuration. Currently empty — tasks are served directly at /tasks."),
        ("package.json","npm config. The start script runs: json-server db.json with json-server-auth middleware."),
    ]),
    Spacer(1, 0.2*cm),
    Paragraph(b("Endpoints provided automatically:"), H3),
    two_col_table([
        ("POST /login",      "json-server-auth endpoint. Validates email + bcrypt-hashed password, returns JWT token."),
        ("GET /tasks",       "Returns all tasks as a JSON array."),
        ("GET /tasks/:id",   "Returns one task by ID."),
        ("POST /tasks",      "Creates a new task. Auto-assigns an ID."),
        ("PUT /tasks/:id",   "Replaces a task entirely."),
        ("DELETE /tasks/:id","Deletes a task."),
    ]),
    Spacer(1, 0.2*cm),
    tip_box("Important",
        "Passwords in db.json must be bcrypt-hashed. json-server-auth uses bcrypt to compare "
        "the plain text you send at login against the stored hash. Plain text passwords will always fail.",
        bg=ORANGE_BG, label_color=ORANGE),
    Spacer(1, 0.3*cm),
]

# ── 10. Error Handling ────────────────────────────────────────────────────────
story += [
    section("10. Error Handling"),
    Spacer(1, 0.2*cm),
    two_col_table([
        ("Network error",    "try/catch wraps every API call. If there's no internet or the server is down, "
                             "the catch block returns an error string shown as a red snackbar."),
        ("API error (4xx/5xx)", "_checkResponse() in ApiService checks the status code. "
                                "If not 2xx, it throws an Exception with the API's error message."),
        ("Form validation",  "Each TextFormField has a validator function. If invalid, "
                             "Flutter shows the error message below the field automatically."),
        ("Empty state",      "If the task list is empty, a friendly icon and message is shown instead of a blank screen."),
        ("Confirmation dialogs", "Delete and logout show AlertDialogs asking 'Are you sure?' before taking action."),
    ]),
    Spacer(1, 0.3*cm),
]

# ── 11. Interview Q&A ─────────────────────────────────────────────────────────
story += [
    section("11. Interview Questions & Answers"),
    Spacer(1, 0.2*cm),
]

qas = [
    ("What is Flutter and why did you use it?",
     "Flutter is Google's UI framework that lets you build apps for iOS, Android, and Web from one codebase "
     "using Dart. I used it because the project required a mobile app and Flutter produces native-quality "
     "UI without writing separate code for each platform."),

    ("What is a Widget in Flutter?",
     "Everything in Flutter is a widget — buttons, text, layouts, even the app itself. "
     "Widgets are either StatelessWidget (never changes after build) or StatefulWidget (can change using setState). "
     "They are cheap to create and Flutter rebuilds only what changed."),

    ("What is the difference between StatelessWidget and StatefulWidget?",
     "StatelessWidget is for UI that never changes after it's built — like a label or an icon. "
     "StatefulWidget has a State object that can store data and call setState() to rebuild the UI. "
     "In this app, all screens are StatefulWidgets because they load data and react to user input."),

    ("What is setState and when do you use it?",
     "setState() tells Flutter that the data inside a StatefulWidget has changed and it should rebuild "
     "the widget. You use it for local state — things only one screen cares about, like a loading spinner, "
     "a form value, or the list of tasks. Example: setState(() => _isLoading = true)."),

    ("What is Provider and why did you use it?",
     "Provider is a state management package that shares data across the widget tree without passing it "
     "manually through constructors. I used it only for AuthService because login state needs to be "
     "accessible everywhere — the routing in main.dart, the logout button in the task list, and the "
     "API service all need to know if the user is logged in."),

    ("What is ChangeNotifier?",
     "A class from Flutter's foundation library. When your class extends ChangeNotifier, it gains the "
     "notifyListeners() method. Call it when data changes and any Consumer or context.watch() "
     "listening to that class will automatically rebuild. AuthService extends it so the UI rebuilds "
     "when the user logs in or out."),

    ("What is a REST API?",
     "REST API is a standard way for apps to talk to a server over HTTP. "
     "It uses standard methods: GET (fetch data), POST (create), PUT (update), DELETE (remove). "
     "The server sends back JSON which the app converts into Dart objects."),

    ("How does authentication work in this app?",
     "The user enters email and password. The app sends POST /login to the API. "
     "The API validates the credentials and returns a JWT token. The app stores this token in "
     "SharedPreferences so it persists after the app is closed. Every API request after that "
     "includes the token in the Authorization header as 'Bearer <token>'. "
     "The app stays logged in until the user taps logout."),

    ("What is a JWT token?",
     "JSON Web Token. A string the server gives you after login that proves who you are. "
     "It has three parts separated by dots: header, payload (user info), and signature. "
     "The server signs it with a secret key so it can't be faked. "
     "You send it with every request so the server knows you're authenticated."),

    ("What is SharedPreferences?",
     "A Flutter package that saves key-value pairs directly on the device (like a tiny local database). "
     "We use it to save the JWT token so the user stays logged in even after closing and reopening the app. "
     "It's simple and perfect for small pieces of data like tokens or settings."),

    ("What is the http package?",
     "A Dart package for making HTTP requests. It provides http.get(), http.post(), http.put(), "
     "http.delete(). You pass a Uri and optional headers/body. It returns a Response object "
     "with statusCode and body (the JSON string from the server)."),

    ("How do you convert JSON to a Dart object?",
     "Using a factory constructor called fromJson. You pass the decoded JSON Map and manually "
     "assign each field. Example: Task.fromJson(json) reads json['title'] and assigns it to title. "
     "jsonDecode() from dart:convert turns the raw JSON string into a Map<String, dynamic>."),

    ("What is the difference between Navigator.push and Navigator.pop?",
     "push() adds a new screen on top of the navigation stack — the user sees the new screen. "
     "pop() removes the current screen and goes back. You can pass data back with pop(context, result) "
     "and receive it with the return value of await Navigator.push(). "
     "In this app, the form screen pops with true when saved, telling the list to refresh."),

    ("What is a Future in Dart?",
     "A Future represents a value that will be available in the future — like an HTTP response. "
     "Mark a function with async and use await to wait for the Future to complete without blocking the UI. "
     "Example: final tasks = await apiService.getTasks() pauses here until the API responds."),

    ("What is async/await?",
     "async marks a function as asynchronous — it can run without blocking the UI. "
     "await pauses execution inside an async function until a Future completes. "
     "Without await the code would continue immediately before the API responds. "
     "All API calls in this app are async/await."),

    ("How does filtering and search work?",
     "All tasks are fetched once from the API and stored in _allTasks list. "
     "A separate _filteredTasks list is what the UI shows. When the user types in the search bar "
     "or taps a filter chip, _applyFilters() runs: it iterates _allTasks and keeps only tasks "
     "matching all active filters, then updates _filteredTasks with setState()."),

    ("What is a FutureBuilder vs loading state with setState?",
     "FutureBuilder is a widget that listens to a Future and rebuilds when it completes. "
     "This app uses manual loading state (bool _isLoading) with setState instead — simpler to "
     "understand and control. When the API call starts, set _isLoading = true. When done, set it to false."),

    ("What is the mounted check and why is it important?",
     "After an await, the widget might have been removed from the tree (user navigated away). "
     "Calling setState() on a disposed widget crashes the app. Checking 'if (!mounted) return' "
     "after every await prevents this. It's a best practice for all async operations in State classes."),

    ("What is the difference between context.read and context.watch?",
     "context.watch<T>() listens for changes — rebuilds the widget when T changes. "
     "context.read<T>() just gets the value once without listening — cheaper, used inside "
     "button callbacks where you don't need the widget to rebuild automatically. "
     "Use watch in build(), use read in event handlers."),

    ("What is a GlobalKey<FormState> used for?",
     "A key that uniquely identifies the Form widget. Calling _formKey.currentState!.validate() "
     "triggers all the validator functions on every TextFormField inside the form. "
     "If any validator returns a non-null string, the field shows that string as an error "
     "and validate() returns false — preventing the save from proceeding."),
]

for q, a in qas:
    story.append(qa(q, a))

story.append(Spacer(1, 0.4*cm))

# ── 12. Quick Cheat Sheet ─────────────────────────────────────────────────────
story += [
    section("12. One-Line Cheat Sheet"),
    Spacer(1, 0.2*cm),
    two_col_table([
        ("main.dart",           "Entry point. Sets up Provider. Routes to Login or TaskList based on token."),
        ("auth_service.dart",   "Login, logout, token storage. Notifies app when login state changes."),
        ("api_service.dart",    "All HTTP calls. Attaches token to every request automatically."),
        ("task.dart",           "Task blueprint. fromJson (API→Dart), toJson (Dart→API), copyWith (editing)."),
        ("login_screen.dart",   "Form → validate → POST /login → save token → navigate."),
        ("task_list_screen.dart","Load tasks → show list → search/filter locally → open detail/create."),
        ("task_detail_screen.dart","Read-only view. Edit opens form. Delete shows dialog then calls API."),
        ("task_form_screen.dart","Create (POST) or Edit (PUT) — same screen, different behaviour."),
        ("task_card.dart",      "Reusable card widget. Title, badges, date, avatar initial."),
        ("db.json",             "Mock database. Passwords must be bcrypt hashed."),
    ]),
    Spacer(1, 0.5*cm),
    tip_box("Final tip for your interview",
        "Be ready to walk through the login flow end-to-end and explain how a task gets created "
        "from button tap to API call to list refresh. Those two flows cover almost every concept in the app."),
    Spacer(1, 0.3*cm),
]

# ── Build ─────────────────────────────────────────────────────────────────────
doc = SimpleDocTemplate(
    OUTPUT,
    pagesize=A4,
    leftMargin=2*cm, rightMargin=2*cm,
    topMargin=2*cm, bottomMargin=2*cm,
    title="Task Manager App — Interview Study Guide",
    author="Task Manager Project",
)

doc.build(story)
print(f"PDF saved to: {OUTPUT}")
