class MyError(Exception):
    def __init__(self, message, number):
        super().__init__(f"{message} (Error code: {number})")
        self.message = message
        self.number = number