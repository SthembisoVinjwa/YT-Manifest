from flask import Flask, request, jsonify, send_file, stream_with_context
import json
from pytube import YouTube
from io import BytesIO

response = ''
link = ''
app = Flask(__name__)

@app.route('/home', methods = ["GET", "POST"])
def home():
    global response
    global link

    resolutions = []

    if request.method == 'POST':
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        link = request_data['link']
        
        try:
            url = YouTube(link)
            url.check_availability()
        except:
            response = 'Error'

        print(url.streams)

        for stream in url.streams.filter(progressive=True) :
            resolutions.append(stream.resolution)

        return jsonify({"title": url.title, "thumbnail": url.thumbnail_url, "resolutions": resolutions, "link": link}) 


@app.route('/download', methods = ["GET", "POST"])
def download():

    if request.method == 'POST':
        buffer = BytesIO()
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        resolution = request_data['resolution']
        url = YouTube(request_data['link'])
        for stream in url.streams.filter(progressive=True, res=resolution) :
            video = stream
            video.stream_to_buffer(buffer)
            buffer.seek(0)
            return send_file(buffer, as_attachment=True, download_name='vid.mp4', mimetype='video/mp4')
if __name__ == '__main__':
    app.run(debug=True)