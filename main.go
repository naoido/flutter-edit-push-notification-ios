package main

import (
	"context"
	"fmt"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

func main() {
	opt := option.WithCredentialsFile("serviceAccountKey.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("error initializing app: %v", err)
		return
	}

	client, err := app.Messaging(context.Background())
	if err != nil {
		log.Fatalf("error getting Messaging client: %v\n", err)
		return
	}

	FCM_TOKEN := "d4ZBGRym30dhhdLz4oiew-:APA91bFjKobKpCm8MiugTlJF2PqVgEPmZWEsjSYxtYfdctizXFGK9LO_iRmIZTmkChS2eKsxSaiHLv52Xt0PIIUnDvzGcxbz5z-pSWoB_-V4A-GEYGCjI-g"
	dataPayload := map[string]string{
		"my_custom_key_1":  "my_custom_value_1_from_go",
		"update_available": "true",
		"item_id":          "item_123_go",
	}

	message := &messaging.Message{
		Data:  dataPayload,
		Token: FCM_TOKEN,
		APNS: &messaging.APNSConfig{
            Payload: &messaging.APNSPayload{
                Aps: &messaging.Aps{
                    Alert: &messaging.ApsAlert{
                        Title: "更新情報",
                        Body:  "詳細を処理中...",
                    },
                    MutableContent: true,
                },
            },
        },
	}

	response, err := client.Send(context.Background(), message)
	if err != nil {
		log.Fatalf("error sending message: %v\n", err)
	}

	fmt.Println("Successfully sent message:", response)
}
