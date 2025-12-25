# Dice Game

A simple web-based dice game for two players built with HTML, CSS, and JavaScript. Players take turns rolling dice to reach a target score first.

## Features

- Two-player dice game
- Customizable player names
- Configurable target score (10-100 points)
- Interactive dice rolling with visual feedback
- Winner celebration animation
- Game reset and restart functionality

## Game Rules

1. Enter player names and set a target score
2. Players take turns rolling the dice
3. First player to reach the target score wins
4. Use "Reset Game" to start a new round or "Restart Game" to reconfigure

## Technology Stack

- **Frontend**: HTML5, CSS3, JavaScript
- **Web Server**: NGINX (Alpine)
- **Containerization**: Docker
- **Orchestration**: Kubernetes with Helm
- **CI/CD**: Jenkins Pipeline
- **Cloud**: AWS EKS

## Local Development

### Prerequisites
- Web browser
- Docker (optional)

### Running Locally
1. Clone the repository:
   ```bash
   git clone https://github.com/devilraj98/Dice-Game.git
   cd Dice-Game
   ```

2. Open `index.html` in your web browser, or serve with a local server:
   ```bash
   python -m http.server 8000
   # or
   npx serve .
   ```

### Docker Development
```bash
# Build the image
docker build -t dice-game .

# Run the container
docker run -p 8080:80 dice-game
```

Access the game at `http://localhost:8080`

## Deployment

### CI/CD Pipeline

The project uses Jenkins for automated deployment across multiple environments:

- **Dev Environment**: `dev-eks` cluster, `dev` namespace
- **Staging Environment**: `staging-eks` cluster, `staging` namespace  
- **Production Environment**: `prod-eks` cluster, `prod` namespace

### Pipeline Stages

1. **Checkout Code** - Pulls latest code from GitHub
2. **Build Docker Image** - Creates containerized application
3. **DockerHub Login** - Authenticates with container registry
4. **Tag & Push Image** - Publishes image to DockerHub
5. **Configure AWS CLI** - Sets up AWS credentials
6. **Deploy to Environments** - Uses Helm to deploy across Dev, Staging, and Prod

### Prerequisites for Deployment

- Jenkins with required plugins
- DockerHub credentials (`dockerhub-creds`)
- AWS IAM credentials (`aws-creds`)
- EKS clusters: `dev-eks`, `staging-eks`, `prod-eks`
- Helm installed on Jenkins agent

### Manual Deployment

```bash
# Deploy to specific environment
helm upgrade --install dice-game-dev ./helm/dice-game \
  --namespace dev --create-namespace \
  --set image.repository=your-dockerhub-username/dice-game \
  --set image.tag=latest
```

## Project Structure

```
Dice-Game/
├── helm/
│   └── dice-game/          # Helm chart for Kubernetes deployment
│       ├── templates/
│       ├── Chart.yaml
│       └── values.yaml
├── images/                 # Dice face images and winner animation
├── scripts/
│   └── index.js           # Game logic
├── style/
│   └── style.css          # Game styling
├── Dockerfile             # Container configuration
├── Jenkinsfile           # CI/CD pipeline definition
└── index.html            # Main game interface
```

## Configuration

### Environment Variables (Jenkins)
- `DOCKERHUB`: DockerHub credentials
- `AWS_CREDS`: AWS IAM credentials  
- `IMAGE_NAME`: Docker image name (default: dice-game)
- `REGION`: AWS region (default: ap-south-1)

### Helm Values
Customize deployment in `helm/dice-game/values.yaml`:
- Image repository and tag
- Service configuration
- Resource limits
- Ingress settings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## License

This project is open source and available under the MIT License.