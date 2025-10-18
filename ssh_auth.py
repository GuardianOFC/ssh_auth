import logging
from flask import Flask, request, jsonify
import pam

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

p = pam.pam()


@app.route('/auth', methods=['POST'])
def auth():
    if not request.json:
        return jsonify({'success': False, 'message': 'invalid request'}), 400

    username = request.json.get('username')
    password = request.json.get('password')

    if not username or not password:
        return jsonify({'success': False, 'message': 'username and password required'}), 400

    logging.info('Authentication request for user: %s', username)

    try:
        if p.authenticate(username, password):
            logging.info('Authentication successful for user: %s', username)
            return jsonify({'success': True, 'message': 'Authentication successful'}), 200
        else:
            logging.info('Authentication failed for user: %s', username)
            return jsonify({'success': False, 'message': 'invalid credentials'}), 401
    except Exception as e:
        logging.error('PAM error: %s', e)
        return jsonify({'success': False, 'message': 'authentication error'}), 500


if __name__ == '__main__':
    app.run(port=5000, debug=True)