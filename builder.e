// Source builder meant to work with Nokia PC Sync,
// but should also work with building sources from an external filesystem.

use "io"
use "ui"
use "form"
use "list"
use "process"
use "string"
use "dialog"
use "textio"

def wait_menu(): String {
    var e = ui_wait_event()
    while (e.kind != EV_MENU) e = ui_wait_event()
    e.value.cast(Menu).text }

def build(form: Form, data: List, options: String) {
    fremove("/tmp/build")
    for (var i = 0, i<(form.size()-1), i+=1) {
        if (form.get(i).cast(CheckItem).checked) {
            fremove("/tmp/" + pathfile(data[i].cast(String))) } }
    for (var i = 0, i<(form.size()-1), i+=1) {
        if (form.get(i).cast(CheckItem).checked) {
            fcopy(data[i].cast(String), "/tmp/" + pathfile(data[i].cast(String))) } }
    var command = "-k ex "
    for (var i = 0, i<(form.size()-1), i+=1) {
        if (data[i].cast(String).endswith(".e")) {
            command += "/tmp/" + pathfile(data[i].cast(String)) + " " } }
    command += "-o /tmp/build " + options
    var p = new Process()
    p.start_wait("/bin/terminal", command.split(' '))
    var q = new Process()
    q.start_wait("/bin/terminal", ["-k", "/tmp/build"]) }

def add_item(form: Form, data: List) {
    var s = run_filechooser("Choose file", "/", ["*.e", "*.eh"])
    data.add(s)
    form.insert(0, new CheckItem("Source:", pathfile(s), true)) }

def delete_item(form: Form, data: List) {
    form.remove(0)
    data.remove(0) }

def load(form: Form, data: List) {
    var f = run_filechooser("Load project", "/home", ["*.bproj"])
    var fio = utfreader(fopen_r(f))
    var r = ""
    var cont = true
    form.clear()
    data.clear()
    while (cont) {
        r = fio.readline()
        if (r == null) cont = false
        if (cont) {
            form.add(new CheckItem("Source:", pathfile(r), true))
            data.add(r) } }
    fio.close() }
    
def save(form: Form, data: List) {
    var f = new Form()
    f.title = "Save project"
    var t = new EditItem("File path:", run_dirchooser("Choose dir", "/home"), EDIT_ANY, 100)
    f.add(t)
    f.add_menu(new Menu("Okay", 0))
    ui_set_screen(f)
    wait_menu()
    if (!t.text.endswith(".bproj")) t.text += ".bproj"
    var fio = utfwriter(fopen_w(t.text))
    for (var i = 0, i<data.len(), i+=1) {
        fio.println(data[i].cast(String)) }
    fio.close() }
    
def main(args: [String]) {
    ui_set_app_title("Builder")
    var form = new Form()
    form.title = "Builder"
    form.add_menu(new Menu("Build", 0))
    form.add_menu(new Menu("Add", 1))
    form.add_menu(new Menu("Delete", 2))
    form.add_menu(new Menu("Load", 3))
    form.add_menu(new Menu("Save", 4))
    form.add_menu(new Menu("Exit", 5, MT_CANCEL))
    var opt = new EditItem("Compiling options:", "-g -lui")
    form.add(opt)
    ui_set_screen(form)
    var data = new List()
    var continue = true
    var response = ""
    do {
        response = wait_menu()
        if (response == "Build") {
            build(form, data, opt.text) }
        else if (response == "Add") {
            add_item(form, data)
            ui_set_screen(form) }
        else if (response == "Delete") {
            delete_item(form, data) }
        else if (response == "Load") {
            load(form, data)
            form.add(opt) }
        else if (response == "Save") {
            save(form, data)
            ui_set_screen(form) }
        else if (response == "Exit") {
            continue = false } }
    while (continue) }
    
