import Back.app.db
from Back.app.db import *
import ollama
from datetime import datetime


# Ollama를 사용한 대화 분석
def analyze_conversation(conversation):
    """
    Ollama API를 통해 대화 데이터를 분석하여 스케줄 생성에 필요한 정보를 추출합니다.

    Parameters:
        conversation (list): 대화 내역

    Returns:
        dict: 분석된 스케줄 데이터
    """

    ''' localhost에서 실행중인 ollama'''
    ollama_client = ollama.Client(base_url="http://localhost:11411")

    prompt = f"""
    The following is a conversation about planning a schedule. Extract the following details from the conversation:
    - Date and time of the meeting
    - Location of the meeting
    - Expected budget for each contents. 

    Conversation:
    {conversation}

    Respond with a JSON containing "name","date", "time", "location","detail", and Array of JSON contianing "name", "category", "amount".
    """
    response = ollama_client.complete(prompt=prompt)
    result = response.get('text', '{}')
    return eval(result)  # Convert the JSON-like string to a Python dictionary

# Firestore에 스케줄 저장
def create_schedule(schedule_data):
    """
    파이어베이스에 새 스케줄을 저장합니다.

    Parameters:
        schedule_data (dict): 생성된 스케줄 데이터

    Returns:
        str: 생성된 문서 ID
    """
    schedule_ref = db.collection('schedule').document()
    schedule_data['id'] = schedule_ref.id  # 문서 ID를 추가
    schedule_ref.set(schedule_data)
    return schedule_ref.id

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

        # 스케줄 데이터 생성
        schedule_data = {
            "name": analyzed_data.get("name"),  # 대화 내용에 따라 이름을 지정
            "detail": analyzed_data.get("detail", "Unknown"),
            "location": analyzed_data.get("location", "Unknown"),
            "start": datetime.strptime(f"{analyzed_data['date']} {analyzed_data['time']}", "%Y-%m-%d %H:%M:%S"),
            "end": None,  # 필요 시 종료 시간을 추가
            "id": None  # 생성 시 자동으로 추가됨
        }

        # Firestore에 저장
        document_id = create_schedule(schedule_data)
        print(f"New schedule created with ID: {document_id}")
        print("Schedule Data:", schedule_data)
    except Exception as e:
        print(f"Error: {e}")
