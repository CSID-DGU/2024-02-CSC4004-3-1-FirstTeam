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
        다음은 일정을 계획하는 대화입니다. 대화에서 다음 세부 정보를 추출하십시오:
        1. 이벤트 이름.
        2. 모임 날짜 (형식: YYYY-MM-DD-HH:MM).
        3. 모임 장소.
        4. 이벤트에 대한 자세한 설명.
        5. 예산 항목 목록, 각 예산 항목에는 다음이 포함됩니다:
           - 항목 이름.
           - 항목 카테고리.
           - 금액 (숫자).
        
        Conversation:
        {prompt_conversation}
        
        Respond with ONLY! a JSON object in Korean containing the following fields:
        - "name": (string) 이벤트 이름.
        - "start": (string) 모임 날짜. (형식: YYYY-MM-DD-HH:MM).
        - "end": (string) 모임 종료 시간. (형식: YYYY-MM-DD-HH:MM).
        - "location": (string) 모임 장소.
        - "detail": (string) 이벤트에 대한 설명
        - "budget": (array) JSON 객체 배열로 구성된 항목으로, 각 객체는 다음을 포함합니다:
           - "name" (string): 예산 항목 이름.
           - "category" (string): 예산 항목 카테고리.
           - "amount" (number): 예산 금액 (숫자)."""

        response = requests.post(url, json={"model": "llama3.2", "prompt": prompt, "stream": False})
        response.raise_for_status()  # HTTP 에러 검사
        print(response.json())
        result = response.json().get('response', '')
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
    {"timestamp": "2024-12-04T18:34:20", "user_id": "Bob", "content": "지난번에 갔던 샤브하우스 어때? 1인당 25000원 정도?"},
    {"timestamp": "2024-12-04T18:35:00", "user_id": "Charlie", "content": "그거 좋네 금요일 7시에 만나자."},
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

