package main

import (
	"html/template"
	"log"
	"net/http"
	"strconv"
	"sync"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type Loan struct {
	Name   string
	Amount float64
	Term   int
	Repaid bool
}

var (
	loans []Loan
	mutex sync.Mutex

	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"path"},
	)
)

func init() {
	prometheus.MustRegister(httpRequestsTotal)
}

func main() {
	// Routes with Prometheus tracking
	http.HandleFunc("/", instrumentHandler("/", showForm))
	http.HandleFunc("/apply", instrumentHandler("/apply", handleLoan))
	http.HandleFunc("/repay", instrumentHandler("/repay", handleRepayment))

	// Static files
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Prometheus metrics endpoint
	http.Handle("/metrics", promhttp.Handler())

	log.Println("Server starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

// Wraps handlers with Prometheus metrics tracking
func instrumentHandler(path string, handlerFunc http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		httpRequestsTotal.WithLabelValues(path).Inc()
		handlerFunc(w, r)
	}
}

func showForm(w http.ResponseWriter, r *http.Request) {
	tmpl := template.Must(template.ParseFiles("templates/index.html"))
	mutex.Lock()
	defer mutex.Unlock()
	tmpl.Execute(w, loans)
}

func handleLoan(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}

	name := r.FormValue("name")
	amount, _ := strconv.ParseFloat(r.FormValue("amount"), 64)
	term, _ := strconv.Atoi(r.FormValue("term"))

	newLoan := Loan{
		Name:   name,
		Amount: amount,
		Term:   term,
		Repaid: false,
	}

	mutex.Lock()
	loans = append(loans, newLoan)
	mutex.Unlock()

	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func handleRepayment(w http.ResponseWriter, r *http.Request) {
	index, _ := strconv.Atoi(r.FormValue("index"))

	mutex.Lock()
	if index >= 0 && index < len(loans) {
		loans[index].Repaid = true
	}
	mutex.Unlock()

	http.Redirect(w, r, "/", http.StatusSeeOther)
}
