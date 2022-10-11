package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

var timeClient *http.Client

func init() {
	if timeClient == nil {
		cert, err := ioutil.ReadFile("./certs/ca.crt")
		if err != nil {
			log.Fatalf("could not open certificate file: %v", err)
		}
		caCertPool := x509.NewCertPool()
		caCertPool.AppendCertsFromPEM(cert)

		certificate, err := tls.LoadX509KeyPair("./certs/tls.crt", "./certs/tls.key")
		if err != nil {
			log.Fatalf("could not load certificate: %v", err)
		}

		timeClient = &http.Client{
			Timeout: time.Minute * 3,
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{
					RootCAs:      caCertPool,
					Certificates: []tls.Certificate{certificate},
				},
			},
		}
	}
}

func getRemoteTime() string {
	r, err := timeClient.Get("https://server.egress-server.svc.cluster.local:8443/time")
	if err != nil {
		log.Fatalf("error making get request: %v", err)
	}

	// Read the response body
	defer r.Body.Close()
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Fatalf("error reading response: %v", err)
	}

	return string(body)
}

func middleHandler(w http.ResponseWriter, r *http.Request) {
	ts := getRemoteTime()
	log.Println(ts)
	io.WriteString(w, ts+"\n")
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "hello world.\n")
}

func main() {
	port := 8080

	// Set up a /hello resource handler
	handler := http.NewServeMux()
	handler.HandleFunc("/time", middleHandler)
	handler.HandleFunc("/hello", helloHandler)

	// Listen to port 8080 and wait
	server := http.Server{
		Addr:    fmt.Sprintf(":%d", port),
		Handler: handler,
	}
	fmt.Printf("(HTTP) Listen on :%d\n", port)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("(HTTP) error listening to port: %v", err)
	}
}
