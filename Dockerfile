FROM  golang:1.20

WORKDIR /app

COPY Loan-app/ .

RUN go mod init loan-app && go mod tidy

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]