# Architecturing-LR3

To run:
```
cd compose
docker-compose up .
```

In browser open to enter RabbitMQ web-UI:
```http://localhost:15671```

Direct exchange with binding to my queue.
![alt text](images/image.png)

Fanout exchange with the same binding
![alt text](images/image-1.png)

Received messages from both exchanges
![alt text](images/image-2.png)

Attempt wrong routing key with direct exchange
![alt text](images/image-3.png)

Topic exchange with routing key passing for any message ending with .log
![alt text](images/image-4.png)

Queue recieved message with error.log routing key
![alt text](images/image-5.png)

And haven't recieved message with user.order routing key
![alt text](images/image-6.png)

Now headers exchange. Creating a binding to send to my queue all messages that contain header format={pdf}
![alt text](images/image-7.png)

Queue recieved message with a specific header:
![alt text](images/image-8.png)

And message with a different header was not sent:
![alt text](images/image-9.png)