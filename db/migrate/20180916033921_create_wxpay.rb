class CreateWxpay < ActiveRecord::Migration[5.2]
  def change
    create_table :wxpays do |t|
      t.string  :no,        index: true, uniq: true
      t.string  :source_no, index: true
      t.string  :out_transaction_no
      t.string  :status
      t.string  :out_source_status
      t.string  :kind
      t.string  :openid
      t.string  :appid
      t.decimal :total_fee,     precision: 12, scale: 2, default: 0.0
      t.decimal :refund_amount, precision: 12, scale: 2, default: 0.0
      t.string  :trade_type
      t.string  :code_url
      t.string  :prepay_id
      t.string  :mweb_url
      t.string  :request_params
      t.string  :response_params

      t.timestamps null: false
    end
  end
end
