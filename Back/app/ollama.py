#import Back.app.db
#from Back.app.db import *
import requests
import json

# Firebase 초기화
#cred = Back.app.db.cred
#firebase_admin.initialize_app(cred)
#db = firestore.client()

# Ollama를 사용한 대화 분석
def analyze_conversation(conversation):
    import requests
    import json

    url = "http://localhost:11434/api/generate"
    headers={"Content-Type": "application/json"}
    try:
        prompt_conversation = "\n".join(
            [f"{entry['user_id']}: {entry['content']}" for entry in conversation]
        )
        prompt = f"""
The following is a conversation about planning a schedule. Extract the following details from the conversation:
1. Name of the event.
2. Date of the meeting (format: YYYY-MM-DD).
3. Time of the meeting (format: HH:MM).
4. Location of the meeting.
5. A detailed description of the event.
6. A list of budgets, where each budget item includes:
   - Name of the item.
   - Category of the item.
   - Amount (in numbers).

Conversation:
{prompt_conversation}

Respond with a JSON object containing the following fields with the Korean translation:
- "name": (string) The name of the event.
- "date": (string) The date of the meeting.
- "time": (string) The time of the meeting.
- "location": (string) The location of the meeting.
- "detail": (string) A detailed description of the event.
- "budget": (array) An array of JSON objects, where each object contains:
   - "name" (string): The name of the budget item.
   - "category" (string): The category of the budget item.
   - "amount" (number): The amount in currency for the budget item.
"""

        response = requests.post(url, json={"model": "llama3.2", "prompt": prompt, "stream": False})
        response.raise_for_status()  # HTTP 에러 검사
        result = response.json().get('response', '{}')
        return json.loads(result)  # 안전하게 JSON 파싱
    except requests.exceptions.RequestException as e:
        print(f"Error during API call: {e}")
        return {}
    except json.JSONDecodeError:
        print("Failed to parse JSON response")
        return {}


# 대화 예제
conversation = [
    {"timestamp": "2024-12-04T18:30:00", "user_id": "Alice", "content": "곧 겨울인데 다 같이 저녁 한 번 먹자. 이번 주 금요일 어때?"},
    {"timestamp": "2024-12-04T18:31:00", "user_id": "Bob", "content": "좋아! 금요일 저녁 괜찮아. 장소는 어디로 할까?"},
    {"timestamp": "2024-12-04T18:32:30", "user_id": "Charlie", "content": "나도 금요일 가능! 따뜻한 거 먹고 싶다. 샤브샤브 어때?"},
    {"timestamp": "2024-12-04T18:33:15", "user_id": "Alice", "content": "샤브샤브 좋다! 근처에 괜찮은 곳 있어?"},
    {"timestamp": "2024-12-04T18:34:20", "user_id": "Bob", "content": "지난번에 갔던 '샤브하우스' 어때? 1인당 25,000원 정도면 될 거야."},
    {"timestamp": "2024-12-04T18:35:00", "user_id": "Charlie", "content": "그거 좋네! 금요일 7시에 만나자."},
    {"timestamp": "2024-12-04T18:36:10", "user_id": "Alice", "content": "좋아, 그러면 이번 주 금요일 7시 '샤브하우스'에서 만나!"}
]

# 실행
if __name__ == "__main__":
    try:
        # Ollama를 사용해 대화 분석
        analyzed_data = analyze_conversation(conversation)
        print("Analyzed data:", analyzed_data)
    finally:
        # Firestore에 스케줄 저장
        print("compelte")

