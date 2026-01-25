import logging
import os

from confluent_kafka import Consumer

import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(name)s - %(message)s",
)


class ConsumerClass:
    def __init__(self, bootstrap_server, topic, group_id):
        """Initializes the consumer."""
        self.bootstrap_server = bootstrap_server
        self.topic = topic
        self.group_id = group_id
        self.consumer = Consumer(
            {"bootstrap.servers": bootstrap_server, "group.id": self.group_id}
        )

    def consume_messages(self):
        """Consume Messages from Kafka."""
        self.consumer.subscribe([self.topic])
        logging.info(f"Successfully subscribed to topic: {self.topic}")

        try:
            while True:
                msg = self.consumer.poll(1.0)
                if msg is None:
                    continue
                if msg.error():
                    logging.error(f"Consumer error: {msg.error()}")
                    continue
                byte_message = msg.value().decode("utf-8")
                decoded_message = byte_message
                logging.info(
                    f"Byte message: {byte_message}, Type: {type(byte_message)}"
                )
                logging.info(
                    f"Decoded message: {decoded_message}, Type: {type(decoded_message)}"  # noqa: E501
                )
        except KeyboardInterrupt:
            pass
        finally:
            self.consumer.close()


if __name__ == "__main__":
    bootstrap_server = "localhost:19092, localhost:29092, localhost:39092"
    topic = "test_env"

    consumer = ConsumerClass(bootstrap_server, topic, "my_group")
    consumer.consume_messages()
