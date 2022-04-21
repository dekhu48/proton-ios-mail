import UIKit
import ProtonCore_UIFoundations
import MBProgressHUD

class SettingsConversationViewController: UITableViewController {

    private enum Key {
        static let headerCell: String = "header_cell"
        static let headerCellHeight: CGFloat = 32.0
    }

    private let viewModel: SettingsConversationViewModel

    init(viewModel: SettingsConversationViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalString._conversation_settings_screen_top_title
        tableView.backgroundView = nil
        tableView.backgroundColor = ColorProvider.BackgroundSecondary
        tableView.register(SwitchTableViewCell.self)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: Key.headerCell)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 48.0
        tableView.separatorInset = .zero
        setUpLoadingObservation()
        setUpRequestFailedObservation()
    }

    private func setUpLoadingObservation() {
        viewModel.isLoading = { [weak self] isLoading in
            guard let view = self?.view else { return }
            if isLoading {
                MBProgressHUD.showAdded(to: view, animated: true)
            } else {
                MBProgressHUD.hide(for: view, animated: true)
            }
        }
    }

    private func setUpRequestFailedObservation() {
        viewModel.requestFailed = { error in
            error.alertToast()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.CellID, for: indexPath)
        cell.backgroundColor = ColorProvider.BackgroundNorm
        guard let switchCell = cell as? SwitchTableViewCell else { return cell }
        viewModel.conversationViewModeHasChanged = { isConversationEnabled in
            switchCell.switchView.setOn(isConversationEnabled, animated: true)
        }

        switchCell.configCell(
            LocalString._conversation_settings_row_title,
            bottomLine: "",
            status: viewModel.isConversationModeEnabled
        ) { [weak self] _, isOn, _ in
            self?.viewModel.switchValueHasChanged(isOn: isOn)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Key.headerCellHeight
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    required init?(coder: NSCoder) {
        nil
    }

}